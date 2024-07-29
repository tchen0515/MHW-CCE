%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of zooscan taxon-specific abundance

%%%%% Required functions, table and raw data
% Yeo-Johnson transformed data was generated from ZooScan_YJtrans.R (MHW-CCE/Insitu_data_process)
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)

clear all
close all

% import station-coordinate chart
addpath '...'
addpath '...'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % generated using package m_mhw

%import data
cd ('...')
raw = readtable('YJ_ZooScanAll.csv',VariableNamingRule="preserve"); % output from ZooScan_YJtrans.R
ALLbio=raw(:,2:end);
% check if temperal&saptial information were misplaced
if ALLbio(:,2).Properties.VariableNames=="Station"  
   ALLbio=renamevars(ALLbio,["Station","Line"],["Line","Station"]);
end
if ALLbio(:,4).Properties.VariableNames=="Cruise mid-date" 
   ALLbio=renamevars(ALLbio,["Cruise mid-date","Station date"],["Station date","Cruise mid-date"]);
end

%% calculate anomalies for each taxa
list=["calanoida","eucalanids","harpacticoida"...
,"oithona","poecilostomatoids","doliolids"...
,"euphausiids","nauplii","pyrosomes","salps"]; % list out all targeted taxa

for a=1:length(list)

taxa=char(string(list(a)));    

% extract time information from cruise number
cruise=datevec(ALLbio.("Station date"));
cruise_yr=cruise(:,1); % 'yyyy'-mm-CC
cruise_month=cruise(:,2); %yyyy-'mm'-CC
cruise_date=cruise(:,3);

% transform into table for table integration
cruise_yr=array2table(cruise_yr);
cruise_month=array2table(cruise_month);
cruise_date=array2table(cruise_date);
cruise_yr.Properties.VariableNames="Year";
cruise_month.Properties.VariableNames="Month";
cruise_date.Properties.VariableNames="Date";

% convert month into season scale
season=table2array(cruise_month);
for s=1:height(season)
    season(s,:)=month2season(season(s,:));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

bioall=[cruise_yr cruise_month cruise_date Season ALLbio];

%Select Cruise and Line-Station to calculate anomalies
%% Select Cruise and Line-Station to calculate anomalies
line=unique(bioall.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(bioall(bioall.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= bioall(bioall.Line==line(i)&bioall.Station==stats(j),:);
        eval(['line',num2str(line(i)),'stat_' ,num2str(stats(j)),'=linestat']);
    end
end

% calculate seasonal average abundance (by month
for i=1:length(line)
    if i==1
        stt=unique(bioall.Station(find(bioall.Line==80),:));
    else
        stt=unique(bioall.Station(find(bioall.Line==90),:));
    end
    for j=1:length(stt)
formatspec ='line%dstat_%d'; %the line-station 
finalstat = sprintf(formatspec,line(i),stt(j)); 
formatspec2 ='aver%d_%d'; %the mean abundance 
finalaver = sprintf(formatspec2,line(i),stt(j)); 
eval(['finalseason=unique(',finalstat,'.Season);']);
eval([finalaver,'=[]']);
for k=1:length(finalseason)
    mon=finalseason(k);
    eval([finalaver,'(k)=mean(',finalstat,'.',taxa,'(',finalstat,'.Season==mon,:));']);
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
for l=1:length(finalseason)
eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:);']);
    end
    end
end


%%% calculate anomalies in each line-station through time

if a==1
    finalano=[]; % create a null array 
end

for k=1:height(bioall)    
    m=bioall.Season(k);
    strm=num2str(m);
    %select correspondent finalaver
formatspec3='aver%d_%d';
finalmean=sprintf(formatspec3,bioall.Line(k),bioall.Station(k));
    %calculate anomalies
      eval(['finalano(k,a)=bioall.',taxa,'(k)-', finalmean,'.("',strm,'");']);
end
end

finalano=array2table(finalano);
finalano.Properties.VariableNames=["ano_calanoida","ano_eucalanids","ano_harpacticoida"...
,"ano_oithona","ano_poecilostomatoids","ano_doliolids"...
,"ano_euphausiids","ano_nauplii","ano_pyrosomes","ano_salps"];

% pull time information and anomalies together
final=[]; 
final(:,1)=bioall.Year;  % Temporal Information  
final(:,2)=bioall.Month;
final(:,3)=bioall.Date;
final(:,4)=bioall.Season;  
final(:,5)=bioall.Line;  % Saptial Information  
final(:,6)=bioall.Station; 
final=array2table(final);
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station"];
anozoo=[final finalano];

%% detect the co-occurrence of MHW event and biological sampling

% insert coordinate information into targeted file (station ID->coodinate)
zoonew=array2table(zeros(height(anozoo),width(anozoo)+2));
for i=1:height(anozoo)
        tf=any(staorder.Line==anozoo(i,:).Line & staorder.Sta==anozoo(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==anozoo(i,:).Line & staorder.Sta==anozoo(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        zoonew(i,:) = [vLat vLon anozoo(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        zoonew(i,:) = [vLat vLon anozoo(i,:)];
    end
end
zoonew.Properties.VariableNames=["Latitude","Longitude","Year","Month","Day","Season","Line","Station",...
        finalano.Properties.VariableNames];
% create columns for inseting MHW
extend=zeros(height(zoonew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend);

% target one station for analysis
for i=1:height(zoonew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=zoonew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=zoonew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(zoonew(i,"Year")) & candidate.st_Mon==table2array(zoonew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(zoonew(i,"Year")) & candidate.st_Mon==table2array(zoonew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(zoonew(i,"Day")) & tm.end_Day>=table2array(zoonew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(zoonew(i,"Day")) & tm.end_Day>=table2array(zoonew(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
zoofinal=[zoonew extend];

%% input corresponding MHW intensity and duration
cd ('...') 
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly

for i=1:height(zoofinal)
    zoofinal.datetime(i,:)=datetime([zoofinal.Year(i),zoofinal.Month(i),zoofinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= zoofinal(zoofinal.occurrence==1,:);

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
cd('...')
filename='OriFinal_MHW_ZooScan.csv';
writetable(sfmhw,filename);

