%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of YJ-transformed nitracline depth

%%%%% Required functions, table and raw data
% Yeo-Johnson transformed data was generated from nitra_YJtrans.R (MHW-CCE/Insitu_data_process)
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)

close all
clear all


% import data & assort the form
cd ('...')
rawnitra = readtable('YJ_Nitracline.csv',VariableNamingRule="preserve");  % output from Nitracline_YJtrans.R
rawnitra(:,1)=[];

%% Select Cruise and Line-Station to calculate anomalies
line=unique(rawnitra.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(rawnitra(rawnitra.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= rawnitra(rawnitra.Line==line(i)&rawnitra.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% calculate seasonal average abundance (by month
for i=1:length(line)
    stats = unique(rawnitra(rawnitra.Line==line(i),:).Station);
   for j=1:length(stats)
formatspec ='line%sstat%s'; %the line-station 
finalstat = sprintf(formatspec,num2str(line(i)*10),num2str(stats(j)*10)); 

formatspec2 ='aver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*10),num2str(stats(j)*10));

eval(['finalseason=unique(',finalstat,'.Season);']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.yj_nitra(',finalstat,'.Season==mon,:);']);
if mean(aver,'omitnan')==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver,"omitnan");']);
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
anonitra=[];

for k=1:height(rawnitra)    
    m=rawnitra.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=num2str(rawnitra.Line(k)*10);
numsta=num2str(rawnitra.Station(k)*10);
%select correspondent finalaver
formatspec1='aver%s_%s';
finalmean1=sprintf(formatspec1,numline,numsta);

%calculate anomalies
        eval(['anonitra(k,:)=rawnitra.yj_nitra(k)-', finalmean1,'.("',strm,'");']);
  
end

% pull time information and anomalies together
final=[]; 
final(:,1)=rawnitra.Line;  % Temporal Information  
final(:,2)=rawnitra.Station; 
final(:,3)=rawnitra.Year;  % Saptial Information  
final(:,4)=rawnitra.Season;
final(:,5)=rawnitra.Month;  
final(:,6)=rawnitra.Day;
final(:,7)=anonitra;  % Anomaly
nitra=array2table(final);
nitra.Properties.VariableNames=["Line","Station","Year","Season","Month","Day","yj_nitracline"];

%% detect the co-occurrence of MHW event and biological sampling
% import station-coordinate chart
addpath '...'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % generated using package m_mhw

% insert coordinate information into targeted file (station ID->coodinate)
nitranew=array2table(zeros(height(nitra),width(nitra)+2));
for i=1:height(nitra)
        tf=any(staorder.Line==nitra(i,:).Line & staorder.Sta==nitra(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==nitra(i,:).Line & staorder.Sta==nitra(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        nitranew(i,:) = [vLat vLon nitra(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        nitranew(i,:) = [vLat vLon nitra(i,:)];
    end
end
nitranew.Properties.VariableNames=["Latitude","Longitude","Line","Station","Year","Season","Month","Day",...
        "ano_nitra"];

% exclude the sampling conducted at the unknown stations & single smapling
nitranew(~nitranew.Latitude,:)=[];
nitranew(~nitranew.ano_nitra,:)=[];

% create columns for inseting MHW
extend=zeros(height(nitranew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend)

% target one station for analysis
for i=1:height(nitranew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=nitranew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=nitranew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(nitranew(i,"Year")) & candidate.st_Mon==table2array(nitranew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(nitranew(i,"Year")) & candidate.st_Mon==table2array(nitranew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(nitranew(i,"Day")) & tm.end_Day>=table2array(nitranew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(nitranew(i,"Day")) & tm.end_Day>=table2array(nitranew(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
nitrafinal=[nitranew extend];

%% input corresponding MHW intensity and duration
cd ('...') 
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly

for i=1:height(nitrafinal)
    nitrafinal.datetime(i,:)=datetime([nitrafinal.Year(i),nitrafinal.Month(i),nitrafinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= nitrafinal(nitrafinal.occurrence==1,:);

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
filename='OriFinal_MHW_nitracline.csv';  % manually type file name
writetable(sfmhw,filename)
