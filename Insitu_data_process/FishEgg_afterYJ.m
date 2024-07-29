%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of fish egg abundance

%%%%% Required functions, table and raw data
% Yeo-Johnson transformed data was generated from FishEgg_YJtrans.R (MHW-CCE/Insitu_data_process)
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)

close all
clear all

% import data & assort the form
cd ('...')
raw = readtable('YJ_FishEgg.csv',VariableNamingRule="preserve"); % Yeo-Johnson transformed data generated from FishEgg_YJtrans.R
fishegg=raw(:,[2:4 8:9 12:15]);
fishegg.Properties.VariableNames = ["Year","Month","Day","Latitude","Longitude"...
    "sardine","anchovy","yj_sardine","yj_anchovy"];

%% calculate anomalies
% convert month into season scale
addpath '...'   %function month2season
season=fishegg.Month;
for s=1:height(season)
    season(s)=month2season(fishegg.Month(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

fegg0=[fishegg(:,1:3) Season fishegg(:,4:end)];

% remove the station that all sampling are zeros
rl_station=unique(fegg0(:,["Season" "Latitude" "Longitude"]),"rows"); % sort out the list of all stations
fegg15=fegg0;
for i=1:height(rl_station)
    idx=find(fegg0.Season==rl_station.Season(i)&...
        fegg0.Latitude==rl_station.Latitude(i)&fegg0.Longitude==rl_station.Longitude(i));
    chose_st=fegg0(idx,:);
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
fegg=fegg15;


% calculate average abundance for each line-station/grid
line=unique(fegg.Latitude); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(fegg(fegg.Latitude==line(i),:).Longitude);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= fegg(fegg.Latitude==line(i)&fegg.Longitude==stats(j),:);
        eval(['line',num2str(line(i)*100),'stat' ,num2str(stats(j)*-100),'=linestat;']);
    end
end

%%calculate average abundance in line-station (by month
for i=1:length(line)
    stats = unique(fegg(fegg.Latitude==line(i),:).Longitude);
   for j=1:length(stats)
formatspec ='line%sstat%s'; %the line-station 
finalstat = sprintf(formatspec,num2str(line(i)*100),num2str(stats(j)*-100)); 

% sardine
formatspec2 ='saraver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*100),num2str(stats(j)*-100));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.yj_sardine(',finalstat,'.Season==mon,:);']);
if mean(aver)==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver)']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:);']);
    end

%anchovy    
    formatspec2 ='ancaver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*100),num2str(stats(j)*-100));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver2=',finalstat,'.yj_anchovy(',finalstat,'.Season==mon,:);']);
if mean(aver2)==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver2)']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:);']);
    end

   end
end

%calculate anomalies
anosar=[]; % sardine
anoanc=[]; % anchovy

for k=1:height(fegg)    
    m=fegg.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=num2str(fegg.Latitude(k)*100);
numsta=num2str(fegg.Longitude(k)*-100);
%select correspondent finalaver
formatspec1='saraver%s_%s';
finalmean1=sprintf(formatspec1,numline,numsta);
formatspec2='ancaver%s_%s';
finalmean2=sprintf(formatspec2,numline,numsta);

%calculate anomalies
        eval(['anosar(k,:)=fegg.yj_sardine(k)-', finalmean1,'.("',strm,'");']);
        eval(['anoanc(k,:)=fegg.yj_anchovy(k)-', finalmean2,'.("',strm,'");']);
   
end


% combine results into one main table
final=[];
final(:,1)=fegg.Year;  % Temporal Information  
final(:,2)=fegg.Month;
final(:,3)=fegg.Day;
final(:,4)=fegg.Season;
final(:,5)=fegg.Latitude; % Spatial information
final(:,6)=fegg.Longitude;
final(:,7)=anosar; %output anomalies
final(:,8)=anoanc;
feggnew=array2table(final);
feggnew.Properties.VariableNames=["Year","Month","Day","Season","Latitude","Longitude",...
    "Ano_yjSardine","Ano_yjAnchovy"];

%% detect the co-occurrence of MHW event and biological sampling
% import station-coordinate chart
addpath '...'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % generated using package m_mhw

% create columns for inseting MHW
extend=zeros(height(feggnew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend)

% target one station for analysis
for i=1:height(feggnew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=feggnew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=feggnew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(feggnew(i,"Year")) & candidate.st_Mon==table2array(feggnew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(feggnew(i,"Year")) & candidate.st_Mon==table2array(feggnew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(feggnew(i,"Day")) & tm.end_Day>=table2array(feggnew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(feggnew(i,"Day")) & tm.end_Day>=table2array(feggnew(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
feggfinal=[feggnew extend];

%% input corresponding MHW intensity and duration
cd ('...') 
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly

for i=1:height(feggfinal)
    feggfinal.datetime(i,:)=datetime([feggfinal.Year(i),feggfinal.Month(i),feggfinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= feggfinal(feggfinal.occurrence==1,:);

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
filename='OriFinal_MHW_FishEgg.csv';  % manually type file name
writetable(sfmhw,filename)
