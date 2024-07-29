%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of Vertically-integrated Chla

%%%%% Required functions, table and raw data
% In-situ Chlorophyll concentration data from in situ sampling data: https://calcofi.org/data/oceanographic-data/bottle-database/
% Function month2season: posted in MHW-CCE/Insitu_data_process
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)

clear all
close all

% import raw data (Source: https://calcofi.org/data/oceanographic-data/bottle-database/)
cd ('.../raw')
raw = readtable('194903-202010_Bottle.csv',VariableNamingRule='preserve'); 

% import station-coordinate chart
addpath '.../package'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % output using package m_mhw1.0
% import standardized MHW intnesity double-array dataset
addpath '.../Satellite_data_processing/output'
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly.m

%% clean up the raw data

% eliminate missing or bas quality value
idx=find(raw.Chlqua~=9);  
ppraw=raw(idx,:);
for v=1:height(ppraw)
    if ppraw.ChlorA(v)<0  
        ppraw.ChlorA(v)=0;
    end
end

% average replication & extract the needed clomuns
ChlA=array2table(ppraw.ChlorA);
ChlA.Properties.VariableNames="Chla"; 
cln=1:5;
ppure=[ppraw(:,cln) ChlA]; % extract smapling inofrmation & averaged Chla value

% indicate station information
stats = char(ppure.Sta_ID);  %use StationID since it is more standardized than lat&long
ppure.Line = ppraw.pH1;   %creatw null columns
ppure.Station = ppraw.pH1;
for i=1:height(ppure)
    ppure.Line(i) = str2double(stats(i,1:5));
    ppure.Station(i) = str2double(stats(i,7:11));
end

% indicate smapling time information
Tinfo=[];
for i=1:height(ppure)
    code=char(ppure.Depth_ID(i));
    yr= str2double(code([1:2 4:5])); %year
    jday=code([14:16]); % Julian day
    eval(['timedate= datetime("1-Jan-',num2str(yr),'")+',jday,'-1;']) % datetime converted from Julian day
    dtime=datevec(timedate);
    month= str2double(code([6:7]));
    date=dtime(:,3);
    Tinfo(i,:)=[yr month date];
end
Tinfo=array2table(Tinfo);
Tinfo.Properties.VariableNames=["Year","Month","Day"];

%convert month into season scale (require function month2season)
addpath '.../package' % function month2season
season=Tinfo.Month;
for s=1:height(season)
    season(s)=month2season(season(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

ppure=[Tinfo Season ppure]; % insert temporal information 

% set 0-m value as 1-m value
ppure.Depthm(ppure.Depthm==0)=1;

%% vertical integration (trapezoidal)
% extract each station
line=unique(ppure.Line);
for i=1:length(line)   % extract rows in each line-station
    stats = unique(ppure(ppure.Line==line(i),:).Station);
    for j=1:length(stats)     % extract data collected in same line-station
        linestat= ppure(ppure.Line==line(i)&ppure.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat;']);
    end
end

% classify data according to sampling time
for i=1:length(line)
    stats = unique(ppure(ppure.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

%list out the sampling times
eval(['sampletime=unique(',finalstat,'(:,1:4),"rows");']); 
 sinfo=zeros(height(sampletime),6);

for q=1:height(sampletime)
    % null matrix for sampling information,removing unnecessary information
    bioaver =zeros(1,1); % null matrix for integrated Chla
    eval(['m_depth=find(table2array(',finalstat,'(:,1))==table2array(sampletime(q,1))&'...  % select the corresponding times (yr-m-d-season)
        'table2array(',finalstat,'(:,2))==table2array(sampletime(q,2))&'...      
        'table2array(',finalstat,'(:,3))==table2array(sampletime(q,3))&'...
        'table2array(',finalstat,'(:,4))==table2array(sampletime(q,4)));']);

% insert unique sampling information
     eval(['special=',finalstat,'(m_depth(1),:);']);
     special2=removevars(special,{'Cst_Cnt','Btl_Cnt','Sta_ID','Depth_ID','Depthm',...
         'Chla' });  % remove unnecessary information
     sinfo(q,:)=table2array(special2);

% calculate trapezoidal vertical integration

eval(['spp=',finalstat,'(m_depth,:);']); % extract the data collected at the same time
spp = sortrows(spp,"Depthm","ascend"); % sort the depth order
ex0=find(spp.Depthm~=0); % exclude 0-m records
depths=spp.Depthm(ex0,:);   
pp=spp.Chla(ex0:end,:);
tf=isnan(pp);  % trapezoidal vertical integration (exculding NA values)
if tf==0
    if length(pp)>1
        bioaver=trapz(depths,pp);
    elseif length(pp)==1
        bioaver=pp;
    end
else
    bioaver=nan;
end

% pull the sampling information and value together 
    aa=sprintf('averfin%dst%dsea%d',line(i)*10,stats(j)*10,table2array(sampletime(q,4)));
    sinfoo=array2table(sinfo(q,:));
    sinfoo.Properties.VariableNames=["Year","Month","Day","Season","Line","Station"];
    bioaver=array2table(bioaver);
    bioaver.Properties.VariableNames="Chla";
    eval([aa,'(q,:)=[sinfoo bioaver];']);
end
end
end

% row bind all the depth averaging data
unistat=table2array(unique(ppure(:,[4 11:12])));  %pull out line station
aa={};
k=1;
x=array2table(zeros(height(ppure),7));  %17384*12 table
for i=1:height(unistat)
    formatspec ='line%dst%dsea%d'; % the line-station 
    aa{i}=sprintf('averfin%dst%dsea%d',unistat(i,2)*10,unistat(i,3)*10,unistat(i,1)); 
    eval(['j=k+height(',aa{i},');']); % determine the size of each table
    eval(['x(k:j-1,:)=',aa{i}]);  % assign each subset table into correspond rows
    eval(['k=k+height(',aa{i},');']);
end
x.Properties.VariableNames=["Year","Month","Day","Season","Line","Station",...
    "Chla"];     

% Remove zero rows
x(~x.Year,:) = [];

%unit transformation after integration (liter to square meter, only for Chla)
x.Chla=x.Chla*10^-3;

%% calculate anomalies
x= x(x.Year~=0,:);
% eliminate missing values
idx=find(isnan(x.Chla)); 
x(idx,:)=[];
chla21=x;

% Select Cruise and Line-Station to calculate anomalies
line=unique(chla21.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(chla21(chla21.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= chla21(chla21.Line==line(i)&chla21.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat;']);
    end
end

%%calculate average abundance in line-station (by month
for i=1:length(line)
    stats = unique(chla21(chla21.Line==line(i),:).Station);
   for j=1:length(stats)
formatspec ='line%dstat%d'; %the line-station 
finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

formatspec2 ='aver%d_%d'; %the mean abundance 
finalaver = sprintf(formatspec2,line(i)*10,stats(j)*10);

eval(['finalseason=unique(',finalstat,'.Season);']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.Chla(',finalstat,'.Season==mon,:);']);
if mean(aver)==0
        eval([finalaver,'(k)=0;']);  
else
        logaver=log10(aver);    % log-transform the raw data
        eval([finalaver,'(k)=mean(logaver(isfinite(logaver)),"omitnan");']);
end
end
eval([finalaver,'=array2table(',finalaver,');']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:);']);
    end
   end
end

% calculate anomalies
finalano=[];
for k=1:height(chla21)    
    m=chla21.Season(k);
    %select correspondent finalaver
formatspec3='aver%d_%d';
finalmean=sprintf(formatspec3,chla21.Line(k)*10,chla21.Station(k)*10);
    %calculate anomalies
    if chla21.Chla(k)==0
      finalano(k,:)=nan;  
    else
    eval(['finalano(k,:)=log10(chla21.Chla(k))-', finalmean,'.("',num2str(m),'");']); 
    end
end

% combine results into one main table
%cloumn binding
final=[];
final(:,1)=chla21.Year;  % Temporal Information  
final(:,2)=chla21.Month;
final(:,3)=chla21.Day;
final(:,4)=chla21.Season;
final(:,5)=chla21.Line; % Spatial information
final(:,6)=chla21.Station;
final(:,7)=finalano;
final=array2table(final); 
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","chla"];

%% detect the co-occurrence of MHW event and biological sampling

% insert coordinate information into targeted file (station ID->coodinate)
chla=final;
chlanew=array2table(zeros(height(chla),width(chla)+2));
for i=1:height(chla)
        tf=any(staorder.Line==chla(i,:).Line & staorder.Sta==chla(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==chla(i,:).Line & staorder.Sta==chla(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        chlanew(i,:) = [vLat vLon chla(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        chlanew(i,:) = [vLat vLon chla(i,:)];
    end
end
chlanew.Properties.VariableNames=["Latitude","Longitude","Year","Month","Day","Season","Line","Station","Chla"];

% remove sampling with unknown coordinate
chlanew(~chlanew.Latitude,:)=[];

% create columns for inseting MHW
extend=zeros(height(chlanew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend);

% target one station for analysis
for i=1:height(chlanew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=chlanew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=chlanew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(chlanew(i,"Year")) & candidate.st_Mon==table2array(chlanew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(chlanew(i,"Year")) & candidate.st_Mon==table2array(chlanew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(chlanew(i,"Day")) & tm.end_Day>=table2array(chlanew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
                extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlachlaing MHW event 
                overlap=tm(tm.st_Day<=table2array(chlanew(i,"Day")) & tm.end_Day>=table2array(chlanew(i,"Day")),:);
                extend(i,1) = array2table(1); %indicated as occurrence
                extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
chlafinal=[chlanew extend];

%% input corresponding MHW intensity and duration

for i=1:height(chlafinal)
    chlafinal.datetime(i,:)=datetime([chlafinal.Year(i),chlafinal.Month(i),chlafinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= chlafinal(chlafinal.occurrence==1,:);

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
cd ('.../output')
filename='OriFinal_MHW_IntChla.csv'  % manually type file name
writetable(sfmhw,filename)
