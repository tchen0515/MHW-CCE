%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of zooplankton displacement volume

%%%%% Required functions, table and raw data
% ZDV data from in situ sampling data: https://calcofi.org/data/marine-ecosystem-data/zooplankton/
% Function month2season: posted in MHW-CCE/Insitu_data_process
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)

clear all
close all

% import data & assort the form
cd ('.../raw')
raw = readtable('195101-201607_1701-1704_1802-1804_Zoop',VariableNamingRule='preserve'); %https://calcofi.org/data/marine-ecosystem-data/zooplankton/
ALLbio=raw(:,[2 4:24]);
ALLbio.Properties.VariableNames = ["Cruise","StationID","Cruz_Sta","Ship_Code","Order_Occ","Cruz_Code",...
    "Line","Station","Lat_Deg","Lat_Min","Lat_Hem","Lon_Deg","Lon_Min","Lon_Hem","Tow_Type",...
    "Net_Loc","End_Time","Tow_Date","Tow_Time","Vol_StrM3","Tow_DpthM","Ttl_PVolC3"];

% import station-coordinate chart
addpath 'MHW-CCE/file'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % output using package m_mhw1.0
% import standardized MHW intnesity double-array dataset
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly.m


% extract time information from cruise number
cruise=datevec(ALLbio.("Tow_Date"));
cruise_yr=cruise(:,1); % 'yyyy'-mm-CC
cruise_month=cruise(:,2); %yyyy-'mm'-CC
cruise_day=cruise(:,3);

% transform into table for table integration
cruise_yr=array2table(cruise_yr);
cruise_month=array2table(cruise_month);
cruise_day=array2table(cruise_day);
cruise_yr.Properties.VariableNames=["Year"];
cruise_month.Properties.VariableNames=["Month"];
cruise_day.Properties.VariableNames=["Date"];

% convert month into season scale
addpath '...' % function month2season
season=table2array(cruise_month);
for s=1:height(season)
    season(s)=month2season(season(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

bioraw=[cruise_yr cruise_month cruise_day Season ALLbio];
bioraw1=bioraw(bioraw.Line>60 & bioraw.Line<93.3,:); % select the sampling in CalCOFI region (line < 60 or >93.3)
bioraw2=bioraw1(bioraw1.Year>=1982,:);  % select the sampling occurred after 1982
bioall=bioraw2(bioraw2.Ttl_PVolC3>0,:);

%% calculate anomalies
% Select Cruise and Line-Station to calculate anomalies
line=unique(bioall.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(bioall(bioall.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= bioall(bioall.Line==line(i)&bioall.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat_' ,num2str(stats(j)*10),'=linestat']);
    end
end

% calculate average abundance for each line-station
stats = unique(bioall.StationID); %use StationID since it is more standardized than lat&long
for i=1:length(stats)
    line= char(stats(i));
    numline=str2double(line(1:5))*10;
    numsta=str2double(line(7:11))*10;
    season= unique(bioall.Season(find(string(bioall.StationID)==line)));
    exstats=bioall(string(bioall.StationID)==line,:); % extract data acquired at same line-station into a seperate table

formatspec ='aver%d_%d'; % the mean abundance 
finalaver = sprintf(formatspec,numline,numsta);
eval([finalaver,'=zeros(1,length(season));']);
for k=1:length(season)
aver=exstats.Ttl_PVolC3(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver)==0
        eval([finalaver,'(:,k)=0;']);    % 0 would become Inf for log-transformation
else
        eval([finalaver,'(:,k)=mean(log10(aver),"omitnan");']);
end
end

eval([finalaver,'=array2table(',finalaver,')']);
for l=1:length(season) % transfer into table
    eval([finalaver,'.Properties.VariableNames{l}=num2str(season(l));']);
end
end

%%% calculate anomalies in each line-station through time
ano=[];
for k=1:height(bioall)    
    m=bioall.Season(k); % pick up the season of each data point first
    strm=num2str(m);
line=char(bioall.StationID(k));
numline=str2double(line(1:5))*10;
numsta=str2double(line(7:11))*10;
%select correspondent finalaver
formatspec1='aver%d_%d';
finalmean1=sprintf(formatspec1,numline,numsta);
%calculate anomalies
    if bioall.Ttl_PVolC3(k)<=0
        ano(k,:)=nan;  
    else
        eval(['ano(k,:)=log10(bioall.Ttl_PVolC3(k))-', finalmean1,'.("',strm,'");']);
    end
end

% pull time information and anomalies together
final=[];
final(:,1)=bioall.Year;  % Temporal Information  
final(:,2)=bioall.Month;
final(:,3)=bioall.Date;
final(:,4)=bioall.Season;
final(:,5)=bioall.Line; % Spatial information
final(:,6)=bioall.Station;
final(:,7)=ano;
zoovol=array2table(final); 
zoovol.Properties.VariableNames=["Year","Month","Date","Season","Line","Station",...
        "Anomaly"];

%% detect the co-occurrence of MHW event and biological sampling

% insert coordinate information into targeted file (station ID->coodinate)
zoovolnew=array2table(zeros(height(zoovol),width(zoovol)+2));
for i=1:height(zoovol)
        tf=any(staorder.Line==zoovol(i,:).Line & staorder.Sta==zoovol(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==zoovol(i,:).Line & staorder.Sta==zoovol(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        zoovolnew(i,:) = [vLat vLon zoovol(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        zoovolnew(i,:) = [vLat vLon zoovol(i,:)];
    end
end

zoovolnew.Properties.VariableNames=["Latitude","Longitude","Year","Month","Day","Season","Line","Station",...
        "Anomaly"];
% create columns for inseting MHW
extend=zeros(height(zoovolnew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend)

% target one station for analysis
for i=1:height(zoovolnew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=zoovolnew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=zoovolnew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(zoovolnew(i,"Year")) & candidate.st_Mon==table2array(zoovolnew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(zoovolnew(i,"Year")) & candidate.st_Mon==table2array(zoovolnew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(zoovolnew(i,"Day")) & tm.end_Day>=table2array(zoovolnew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(zoovolnew(i,"Day")) & tm.end_Day>=table2array(zoovolnew(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
zoovolfinal=[zoovolnew extend];

%% input corresponding MHW intensity and duration

for i=1:height(zoovolfinal)
    zoovolfinal.datetime(i,:)=datetime([zoovolfinal.Year(i),zoovolfinal.Month(i),zoovolfinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= zoovolfinal(zoovolfinal.occurrence==1,:);

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
cd ('.../output')
filename='OriFinal_MHW_ZDV.csv';  % manually type file name
writetable(sfmhw,filename)

