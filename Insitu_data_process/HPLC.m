%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of HPLC

%%%%% Required functions, table and raw data
% HPLC data from in situ sampling data: https://doi.org/10.6073/pasta/831e099fb086954d3d73638d33d3dd05
% Function month2season: posted in MHW-CCE/Insitu_data_process
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)
close all
clear all

% import station-coordinate chart
addpath '.../package'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % output using package m_mhw1.0
% import standardized MHW intnesity double-array dataset
addpath '.../Satellite_data_processing/output'
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly.m

% import data https://doi.org/10.6073/pasta/831e099fb086954d3d73638d33d3dd05
cd('.../raw')
rawhplc = readtable('Q-CCE-HPLC (Datazoo)10182023.xls','Sheet','Q-CCE-HPLC (Datazoo)'); %HPLC rawest data with dateime

% eliminate bad-quality data
rawhplc = rawhplc(rawhplc.QualityControlFlag==0,:);

% insert the date information 
Date=datevec(rawhplc.DatetimeGMT);
rawhplc.Year=Date(:,1);
rawhplc.Month=Date(:,2);
rawhplc.Day=Date(:,3);

% extract the targeted variables' columns
hplc2=rawhplc(:,[61:63 1:10 12:13 16:17 39:40 47:48]); %, DV chla, fucoxanthin, hexanoyloxfucoxanthin

% combine data from two different labs
hplc3=hplc2;
for i=1:height(hplc2)
    if isnan(hplc2.TotalChlorophyllA_Goericke_SIO_(i))    %TotalChla
        hplc3.TotalChlorophyllA_Goericke_SIO_(i)=hplc3.TotalChlorophyllA_UMCES_(i);
    end
    if isnan(hplc2.DivinylChlorophyllA_Goericke_SIO_(i))   %DV chla
        hplc3.DivinylChlorophyllA_Goericke_SIO_(i)=hplc2.DivinylChlorophyllA_UMCES_(i);
    end
    if isnan(hplc2.Fucoxanthin_Goericke_SIO_(i))   %fucoxanthin
       hplc3.Fucoxanthin_Goericke_SIO_(i)=hplc2.Fucoxanthin_UMCES_(i); 
    end
    if isnan(hplc2.x19__hexanoyloxyfucoxanthin_Goericke_SIO_(i))   %hexanoyloxfucoxanthin
       hplc3.x19__hexanoyloxyfucoxanthin_Goericke_SIO_(i)=hplc2.x19__hexanoyloxyfucoxanthin_UMCES_(i);
    end
end

hplc3=hplc3(:,[1:13 14 16 18 20]); %remove the "backup" columns
hplc3.Properties.VariableNames(14:17)={'TotalChla','dvChla','Fucoxanthin','hexfucox'};

hplc3 = hplc3(hplc3.Depth<=16,:); 
idx=find(isnan(hplc3.dvChla)|isnan(hplc3.hexfucox)|isnan(hplc3.Fucoxanthin)); % eliminate missing values 
hplc3(idx,:)=[];
hplc3.Line=str2double(hplc3.Line);
hplc3.Station=str2double(hplc3.Station);

%convert month into season scale
addpath '...' % function month2season
season=[];
for s=1:height(hplc3)
    season(s,:)=month2season(hplc3.Month(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";
% transform into table for table integration
hplc=[hplc3(:,1:3) Season hplc3(:,4:end)];

% find out Cruise and Line-Station 
line=unique(hplc.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(hplc(hplc.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= hplc(hplc.Line==line(i)&hplc.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% extract index name (col.15~52) for further steps
para=strings(3,1);
for i=1:3
    para(i)= hplc.Properties.VariableNames{i+15}; 
end

% classify data according to sampling time
for i=1:length(line)
    stats = unique(hplc(hplc.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

%list out the sampling times
    eval(['sampletime=unique(',finalstat,'(:,1:4),"rows")']); 
    sinfo=zeros(height(sampletime),8); % null matrix for sampling information,removing unnecessary information
    bioaver =zeros(height(sampletime),3); % null matrix for average biological values

for q=1:height(sampletime)
    eval(['m_depth=find(table2array(',finalstat,'(:,1))==table2array(sampletime(q,1))&'...  % select the corresponding times (yr-m-d-season)
        'table2array(',finalstat,'(:,2))==table2array(sampletime(q,2))&'...      
        'table2array(',finalstat,'(:,3))==table2array(sampletime(q,3))&'...
        'table2array(',finalstat,'(:,4))==table2array(sampletime(q,4)))']);

% insert unique sampling information
    eval(['special=',finalstat,'(m_depth(1),:)']);
    special2=removevars(special,{'AssociatedBottleNumber','BottleNumber','CastNumber','Depth','DatetimeGMT'...
        'studyName','TotalChla','dvChla','Fucoxanthin','hexfucox'});  % remove unnecessary information
    sinfo(q,:)=table2array(special2);

% calculate average for each variables
    for p=1:length(para) 
        eval(['bioaver(q,',num2str(p),')=mean(',finalstat,'(m_depth,:).("',char(para(p)),'"))']) %variable names into para
    end
    
end
% pull the sampling information and value together 
    aa=sprintf('averfin%dst%d',line(i)*10,stats(j)*10);
    sinfo=array2table(sinfo);
    sinfo.Properties.VariableNames=["Year","Month","Day","Season","Latitude","Longitude","Line","Station"];
    bioaver=array2table(bioaver);
    bioaver.Properties.VariableNames=["dvChla","Fucoxanthin","hexfucox"];
    eval([aa,'=[sinfo bioaver]']);

end
end

% row bind all the depth averaging data
unistat=table2array(unique(hplc(:,["Line" "Station"])));  %pull out line station
aa={};
k=1;
x=array2table(zeros(2792,11));
for i=1:height(unistat)
    formatspec ='line%dstat%d'; % the line-station 
    aa{i}=sprintf('averfin%dst%d',unistat(i,1)*10,unistat(i,2)*10); 
    eval(['j=k+height(',aa{i},')']); % determine the size of each table
    eval(['x(k:j-1,:)=',aa{i}]);  % assign each subset table into correspond rows
    eval(['k=k+height(',aa{i},')']);
end
x.Properties.VariableNames=["Year","Month","Day","Season","Latitude","Longitude","Line","Station",...
    "dvChla","Fucoxanthin","hexfucox"];  

%% calculate anomalies
hplcraw=x;
% Select Cruise and Line-Station to calculate anomalies
line=unique(hplcraw.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(hplcraw(hplcraw.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= hplcraw(hplcraw.Line==line(i)&hplcraw.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

%%calculate average abundance in line-station (by month
for i=1:length(line)
    stats = unique(hplcraw(hplcraw.Line==line(i),:).Station);
   for j=1:length(stats)
formatspec ='line%dstat%d'; %the line-station 
finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

% dvChla
formatspec2 ='dvaver%d_%d'; %the mean abundance 
finalaver = sprintf(formatspec2,line(i)*10,stats(j)*10);

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.dvChla(',finalstat,'.Season==mon,:)']);
if mean(aver)==0
        eval([finalaver,'(k)=0']);  
else
    logaver=log10(aver);    
    eval([finalaver,'(k)=mean(logaver(isfinite(logaver)),"omitnan")']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:)']);
    end

% hexfucox
formatspec2 ='hexaver%d_%d'; %the mean abundance 
finalaver = sprintf(formatspec2,line(i)*10,stats(j)*10);

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver2=',finalstat,'.hexfucox(',finalstat,'.Season==mon,:)']);
if mean(aver)==0
        eval([finalaver,'(k)=0']);  
else
        logaver2=log10(aver2);
        eval([finalaver,'(k)=mean(logaver2(isfinite(logaver2)),"omitnan")']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:)']);
    end
% Fucoxanthin
formatspec2 ='fucoaver%d_%d'; %the mean abundance 
finalaver = sprintf(formatspec2,line(i)*10,stats(j)*10);

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver3=',finalstat,'.Fucoxanthin(',finalstat,'.Season==mon,:)']);
if mean(aver)==0
        eval([finalaver,'(k)=0']);  
else
        logaver3=log10(aver3);
        eval([finalaver,'(k)=mean(logaver3(isfinite(logaver3)),"omitnan")']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:)']);
    end
   end
end

%%calculate anomalies
anodv=[]; % dvChla
anohex=[]; % hexfuco
anofuco=[]; % fuco

for k=1:height(hplcraw)    
    m=hplcraw.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=hplcraw.Line(k)*10;
numsta=hplcraw.Station(k)*10;
%select correspondent finalaver
formatspec1='dvaver%d_%d';
finalmean1=sprintf(formatspec1,numline,numsta);
formatspec2='hexaver%d_%d';
finalmean2=sprintf(formatspec2,numline,numsta);
formatspec3='fucoaver%d_%d';
finalmean3=sprintf(formatspec3,numline,numsta);
%calculate anomalies
    if hplcraw.dvChla(k)<=0
        anodv(k,:)=nan;  
    else
        eval(['anodv(k,:)=log10(hplcraw.dvChla(k))-', finalmean1,'.("',strm,'")']);
    end
    if hplcraw.hexfucox(k)<=0
        anohex(k,:)=nan;  
    else
        eval(['anohex(k,:)=log10(hplcraw.hexfucox(k))-', finalmean2,'.("',strm,'")']);
    end
    if hplcraw.Fucoxanthin(k)<=0
        anofuco(k,:)=nan;  
    else
        eval(['anofuco(k,:)=log10(hplcraw.Fucoxanthin(k))-', finalmean3,'.("',strm,'")']);
    end
end

%% combine results into one main table
final=[];
final(:,1)=hplcraw.Year;  % Temporal Information  
final(:,2)=hplcraw.Month;
final(:,3)=hplcraw.Day;
final(:,4)=hplcraw.Season;
final(:,5)=hplcraw.Line; % Spatial information
final(:,6)=hplcraw.Station;
final(:,7)=anodv; %output anomalies
final(:,8)=anohex;
final(:,9)=anofuco;
final=array2table(final);
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station",...
    "dvChla","hexfucox","fucox"];

%% detect the co-occurrence of MHW event and biological sampling
hplcc=final;
% insert coordinate information into targeted file (station ID->coodinate)
hplcnew=array2table(zeros(height(hplcc),width(hplcc)+2));
for i=1:height(hplcc)
        tf=any(staorder.Line==hplcc(i,:).Line & staorder.Sta==hplcc(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==hplcc(i,:).Line & staorder.Sta==hplcc(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        hplcnew(i,:) = [vLat vLon hplcc(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        hplcnew(i,:) = [vLat vLon hplcc(i,:)];
    end
end
hplcnew.Properties.VariableNames=["Latitude","Longitude","Year","Month","Day","Season","Line","Station",...
        "dvChla","hexfucox","fucox"];

% create columns for inseting MHW
extend=zeros(height(hplcnew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend);

% target one station for analysis
for i=1:height(hplcnew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=hplcnew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=hplcnew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(hplcnew(i,"Year")) & candidate.st_Mon==table2array(hplcnew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(hplcnew(i,"Year")) & candidate.st_Mon==table2array(hplcnew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(hplcnew(i,"Day")) & tm.end_Day>=table2array(hplcnew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(hplcnew(i,"Day")) & tm.end_Day>=table2array(hplcnew(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
hplcfinal=[hplcnew extend];

%% input corresponding MHW intensity and duration
for i=1:height(hplcfinal)
    hplcfinal.datetime(i,:)=datetime([hplcfinal.Year(i),hplcfinal.Month(i),hplcfinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= hplcfinal(hplcfinal.occurrence==1,:);

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
    sfmhw1=sfmhw(t,:)
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
filename='OriFinal_MHW_HPLC.csv';  % manually type file name
writetable(sfmhw,filename)
