%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of fish larvae abundance

%%%%% Required functions, table and raw data
% Yeo-Johnson transformed data was generated from FishLarvae_YJtrans.R (MHW-CCE/Insitu_data_process)
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)

clear all
close all

% import YJ_trans_FishLarve.csv
cd ('...')
ALLbio = readtable('YJ_FishLarve.csv',VariableNamingRule='preserve'); % Yeo-Johnson transformed data generated from FishLarvae_YJtrans.R
ALLbio= ALLbio(:,2:end);

%% calculate anomalies
% elminate the sampling only coducted at certain station once
line=ALLbio.Line;
station=ALLbio.Station;
info=[line,station];
rl_sampling=unique(info,'rows'); % sort out the list of daliy sampling at each station
rl_sampling=array2table(rl_sampling);
rl_sampling.Properties.VariableNames=["Line","Station"];
for i=1:height(rl_sampling)
    idx=find(ALLbio.Line==rl_sampling.Line(i)&ALLbio.Station==rl_sampling.Station(i));
if length(idx)==1
    ALLbio.Year(idx)=0;
end
end
fegg=ALLbio(ALLbio.Year~=0,:);

% remove the station that all sampling are zeros
rl_station=unique(fegg(:,["Season" "Latitude" "Longitude"]),"rows"); % sort out the list of all stations
fegg15=fegg;
for i=1:height(rl_station)
    idx=find(fegg.Season==rl_station.Season(i)&...
        fegg.Latitude==rl_station.Latitude(i)&fegg.Longitude==rl_station.Longitude(i));
    chose_st=fegg(idx,:);
if sum(chose_st.sardine)==0  % check sardine egg number
    fegg15(idx,"sardine")=array2table(nan(length(idx),1));
    fegg15(idx,"yj_sardine")=array2table(nan(length(idx),1));
end
if sum(chose_st.anchovy)==0  % check anchovy egg number
    fegg15(idx,"anchovy")=array2table(nan(length(idx),1));
    fegg15(idx,"yj_anchovy")=array2table(nan(length(idx),1));
end
end
%elminate rows that both sardine & anchovy are NA
idx=find(isnan(fegg15.sardine)==1&isnan(fegg15.anchovy)==1);
fegg15(idx,:)=[];
bioall=fegg15;

%Select Cruise and Line-Station to calculate anomalies
line=unique(bioall.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(bioall(bioall.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= bioall(bioall.Line==line(i)&bioall.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% calculate seasonal average abundance (by month
for i=1:length(line)
    stats = unique(bioall(bioall.Line==line(i),:).Station);
   for j=1:length(stats)
formatspec ='line%sstat%s'; %the line-station 
finalstat = sprintf(formatspec,num2str(line(i)*10),num2str(stats(j)*10)); 

% sardine
formatspec2 ='saraver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*10),num2str(stats(j)*10));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.yj_sardine(',finalstat,'.Season==mon,:);']);
if mean(aver,'omitnan')==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver,"omitnan")']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:);']);
    end

%anchovy    
    formatspec2 ='ancaver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*10),num2str(stats(j)*10));

eval(['finalseason=unique(',finalstat,'.Season);']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver2=',finalstat,'.yj_anchovy(',finalstat,'.Season==mon,:);']);
if mean(aver2,'omitnan')==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver2,"omitnan");']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:);']);
    end

   end
end


%%% calculate anomalies in each line-station through time
anosar=[]; % sardine
anoanc=[]; % anchovy

for k=1:height(bioall)    
    m=bioall.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=num2str(bioall.Line(k)*10);
numsta=num2str(bioall.Station(k)*10);
%select correspondent finalaver
formatspec1='saraver%s_%s';
finalmean1=sprintf(formatspec1,numline,numsta);
formatspec2='ancaver%s_%s';
finalmean2=sprintf(formatspec2,numline,numsta);

%calculate anomalies
        eval(['anosar(k,:)=bioall.yj_sardine(k)-', finalmean1,'.("',strm,'");']);
        eval(['anoanc(k,:)=bioall.yj_anchovy(k)-', finalmean2,'.("',strm,'");']);
   
end

% pull time information and anomalies together
final=[]; 
final(:,1)=bioall.Line;  % Temporal Information  
final(:,2)=bioall.Station;
final(:,3)=bioall.Latitude;
final(:,4)=bioall.Longitude;  
final(:,5)=bioall.Year;  % Saptial Information  
final(:,6)=bioall.Season;
final(:,7)=bioall.Month;  
final(:,8)=bioall.Day;
final(:,9)=anosar;  % Anomaly
final(:,10)=anoanc;
larvenew=array2table(final);
larvenew.Properties.VariableNames=["Line","Station","Latitude","Longitude","Year","Season",...
    "Month","Day","yj_sardine","yj_anchovy"];

%% detect the co-occurrence of MHW event and biological sampling
% import station-coordinate chart
addpath '...'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % generated using package m_mhw

% create columns for inseting MHW
extend=zeros(height(larvenew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend);

% target one station for analysis
for i=1:height(larvenew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=larvenew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=larvenew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(larvenew(i,"Year")) & candidate.st_Mon==table2array(larvenew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(larvenew(i,"Year")) & candidate.st_Mon==table2array(larvenew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(larvenew(i,"Day")) & tm.end_Day>=table2array(larvenew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(larvenew(i,"Day")) & tm.end_Day>=table2array(larvenew(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
larvaefinal=[larvenew extend];

%% input corresponding MHW intensity and duration
cd ('...') 
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly

for i=1:height(larvaefinal)
    larvaefinal.datetime(i,:)=datetime([larvaefinal.Year(i),larvaefinal.Month(i),larvaefinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= larvaefinal(larvaefinal.occurrence==1,:);

%%pick out the SST anomaly at corresponding time
sstano=[];
for i=1:height(sfmhw) 
sfmhw1=sfmhw(i,:);
% transfer cooridnate (raw coordinate is flipped compared to current data)
ts_x = (sfmhw1.mhw_long+140.125)/0.25;
ts_y = (sfmhw1.mhw_lat-24.875)/0.25;

% transfer date into time order
dorder=datenum(sfmhw1.datetime)-datenum(1982,1,1)+1;

%pick out the MHW intensity at that certain time

%%%%%%% be sure to see if you are using original or SD version (mhw_ts/mhw_sdts)
sstano(i,:)=mhw_sdts(ts_x,ts_y,dorder); %(lon,lat,day)    
%%%%%%

end

sfmhw.anoSST=sstano; %insert into main table

% pick out the MHW duration at certain time
rl=[];
for t=1:height(sfmhw)
    sfmhw1=sfmhw(t,:);
% pick out mhw_onset date
    onset_date = num2str(sfmhw1.mhw_onset);
    onset_yr = str2double(onset_date(1:4));
    onset_mo = str2double(onset_date(5:6));
    onset_d = str2double(onset_date(7:8));
    onset_datenum = datenum(onset_yr,onset_mo,onset_d);

% calculate the real-time duration
    rl(t,:) = datenum(sfmhw1.datetime(1))-onset_datenum+1;
end

sfmhw.rlduration=rl; %insert into main table

% export data
cd ('...')
filename='OriFinal_MHW_FishLarvae.csv'; 
writetable(sfmhw,filename)
