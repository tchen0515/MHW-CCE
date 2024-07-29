%%% Acquire the co-occurrence of MHW characteristics (intensity &
%%% duration) and the anomaly of picoplankton and bacteria abundance

%%%%% Required functions, table and raw data
% Flow cytometry data from in situ sampling data: https://doi.org/10.6073/pasta/994126a7ba3d90250cf371d92b134538
% Function month2season: posted in MHW-CCE/Insitu_data_process
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% Table of MHW occurrence in grid cell point in CCE region from 1982~2021: calculated using package m_mhw.m and posted in MHW-CCE
% Double array of SD-SST anomaly: calculated using code sd_SSTanomaly (MHW-CCE/satellite_data_process)

clear all
close all

% import station-coordinate chart
addpath '.../package'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve'); %available at https://calcofi.org/sampling-info/station-positions/
% import MHW event table (with coordinate)
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve'); % output using package m_mhw1.0
% import standardized MHW intnesity double-array dataset
addpath '.../Satellite_data_processing/output'
load('mhw_stdanomaly_240409.mat') %calculated from code sd_SSTanomaly.m

% import raw data (Source: https://doi.org/10.6073/pasta/8ebed2a2ac22a27b23e7ba98f10dcbb4)
cd (...)
raw = readtable('picoBacteria_194.csv',VariableNamingRule='preserve');
raw(:,16)=[];
raw.Properties.VariableNames(4)=["DatetimeUTC"];
raw.Properties.VariableNames(7:8)=["Latitude","Longitude"];
raw.Properties.VariableNames(11:15)=["Depth","HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];
idx=find(isnan(raw.Line)|isnan(raw.Station)|isnan(raw.HeteroBacteria)); 
raw(idx,:)=[];

%% clean data and average the data in the surface layers
% extract time information from Datetime
time=datevec(raw.DatetimeUTC); % year is cloumn 1,while month is column 2
cruise_ym=[];
cruise_ym(:,1)=time(:,1);
cruise_ym(:,2)=time(:,2);
cruise_ym(:,3)=time(:,3);

%convert month into season scale
addpath '...'  %function month2season
season=[];
for s=1:height(time)
    season(s,:)=month2season(time(s,2));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

% transform into table for table integration
cruise_ym=array2table(cruise_ym);
cruise_ym.Properties.VariableNames=["Year","Month","Date"];
pico=[cruise_ym Season raw];

% select sampling only in surface depths (<10m)
pico10=pico(pico.Depth<=10,:);

%% find out Cruise and Line-Station 
line=unique(pico10.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(pico10(pico10.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= pico10(pico10.Line==line(i)&pico10.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat;']);
    end
end

% extract index name (col.15~52) for further steps
para=strings(4,1);
for i=1:4
    para(i)= pico10.Properties.VariableNames{i+15}; 
end

% classify data according to sampling time
for i=1:length(line)
    stats = unique(pico10(pico10.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

%list out the sampling times
    eval(['sampletime=unique(',finalstat,'(:,1:4),"rows")']); 
    sinfo=zeros(height(sampletime),8); % null matrix for sampling information,removing unnecessary information
    bioaver =zeros(height(sampletime),4); % null matrix for average biological values

for q=1:height(sampletime)
    eval(['m_depth=find(table2array(',finalstat,'(:,1))==table2array(sampletime(q,1))&'...  % select the corresponding times (yr-m-d-season)
        'table2array(',finalstat,'(:,2))==table2array(sampletime(q,2))&'...      
        'table2array(',finalstat,'(:,3))==table2array(sampletime(q,3))&'...
        'table2array(',finalstat,'(:,4))==table2array(sampletime(q,4)));']);

% insert unique sampling information
    eval(['special=',finalstat,'(m_depth(1),:)']);
    special2=removevars(special,{'Assoc. Bottle Number','Bottle Number','Cruise','Depth','DatetimeUTC','Event Number'...
        'studyName','HeteroBacteria','Synechococcus','Prochlorococcus','Picoeukaryotes'});  % remove unnecessary information
    sinfo(q,:)=table2array(special2);

% calculate average for each variables
    for p=1:length(para) 
        eval(['bioaver(q,',num2str(p),')=mean(',finalstat,'(m_depth,:).("',char(para(p)),'"));']) %variable names into para
    end
    
end
% pull the sampling information and value together 
    aa=sprintf('averfin%dst%d',line(i)*10,stats(j)*10);
    sinfo=array2table(sinfo);
    sinfo.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","Latitude","Longitude"];
    bioaver=array2table(bioaver);
    bioaver.Properties.VariableNames=["HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];
    eval([aa,'=[sinfo bioaver]']);

end
end

% bind all the depth averaging data by rows
unistat=table2array(unique(pico10(:,9:10)));  %pull out line station
aa={};
k=1;
x=array2table(zeros(2792,12));
for i=1:height(unistat)
    formatspec ='line%dstat%d'; % the line-station 
    aa{i}=sprintf('averfin%dst%d',unistat(i,1)*10,unistat(i,2)*10); 
    eval(['j=k+height(',aa{i},');']); % determine the size of each table
    eval(['x(k:j-1,:)=',aa{i}],';');  % assign each subset table into correspond rows
    eval(['k=k+height(',aa{i},');']);
end
x.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","Latitude","Longitude",...
    "HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];     

%% calculate anomalies
% remove bad quality data
idx=find(isnan(x.Line)|isnan(x.Station)|isnan(x.HeteroBacteria)); 
x(idx,:)=[];
pico=x; %[cruise_ym Season raw];

% Select Cruise and Line-Station to calculate anomalies
line=unique(pico.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(pico(pico.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= pico(pico.Line==line(i)&pico.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% extract index name (col.15~52) for further steps
para=strings(4,1);
for i=1:4
    para(i)= pico.Properties.VariableNames{i+8}; 
end

% calculate average abundance in line-station (by season
for i=1:length(line)
    stats = unique(pico(pico.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

eval(['finalseason=unique(',finalstat,'.Season)']);
    
for p=1:length(para) %the mean abundance of each category
    finalaver = sprintf('p%daver%d_%d',p,line(i)*10,stats(j)*10);

eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['selectseason=',finalstat,'(',finalstat,'.Season==mon,:)']);
    eval(['aver=selectseason.("',char(para(p)),'");']);
 
    % eval(['pico.("',char(para(1)),'")'])
if mean(aver,'omitnan')==0
        eval([finalaver,'(k)=0']);  
else
        logaver1=log10(aver);
        eval([finalaver,'(k)=mean(logaver1(isfinite(logaver1)),"omitnan");']);
end
end

eval([finalaver,'=array2table(',finalaver,')']);
for l=1:length(finalseason)
    eval([finalaver,'.Properties.VariableNames{l}=num2str(finalseason(l));']);
end
    end
end
end

%calculate anomalies
for p=1:4 % anomalies result for each category
    eval(['ano',num2str(p),'=[]']);
    eval(['selectmicro=pico.("',char(para(p)),'");']);
for k=1:height(pico)
    line=pico.Line(k);
    stats=pico.Station(k);
    m=pico.Season(k); % pick up the season of each data point first
    strm=num2str(m);
finalaver = sprintf('p%daver%d_%d',p,line*10,stats*10);  %select correspondent average  

%calculate anomalies (for each data point)
if selectmicro(k)<=0
        eval(['ano',num2str(p),'(k,:)=nan']);  
    else
        eval(['ano',num2str(p),'(k,:)=log10(selectmicro(k))-', finalaver,'.("',strm,'");']);
end
end
end

% combine results into one main table
%cloumn binding
final=[];
final(:,1)=pico.Year;  % Temporal Information  
final(:,2)=pico.Month;
final(:,3)=pico.Date;
final(:,4)=pico.Season;
final(:,5)=pico.Line; % Spatial information
final(:,6)=pico.Station;
final(:,7)=pico.Latitude;
final(:,8)=pico.Longitude;
for p=1:4
    eval(['final(:,p+8)=ano',num2str(p),';']); 
end
pico=array2table(final); 
pico.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","Latitude","Longitude",...
    "HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];

%% detect the co-occurrence of MHW event and biological sampling

% insert coordinate information into targeted file (station ID->coodinate)
piconew=array2table(zeros(height(pico),width(pico)+2));
for i=1:height(pico)
        tf=any(staorder.Line==pico(i,:).Line & staorder.Sta==pico(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==pico(i,:).Line & staorder.Sta==pico(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        piconew(i,:) = [vLat vLon pico(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        piconew(i,:) = [vLat vLon pico(i,:)];
    end
end
piconew.Properties.VariableNames=["Latitude","Longitude","Year","Month","Day","Season","Line","Station",...
        "Stat_lat","Stat_long","HeteroBacteria","Prochlorococcus",...
        "Synechococcus","Picoeukaryotes"];
% create columns for inseting MHW
extend=zeros(height(piconew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend);

% target one station for analysis
for i=1:height(piconew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=piconew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=piconew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(piconew(i,"Year")) & candidate.st_Mon==table2array(piconew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(piconew(i,"Year")) & candidate.st_Mon==table2array(piconew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(piconew(i,"Day")) & tm.end_Day>=table2array(piconew(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(piconew(i,"Day")) & tm.end_Day>=table2array(piconew(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
picofinal=[piconew extend];

%% input corresponding MHW intensity and duration

for i=1:height(picofinal)
    picofinal.datetime(i,:)=datetime([picofinal.Year(i),picofinal.Month(i),picofinal.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= picofinal(picofinal.occurrence==1,:);

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
filename='OriFinal_MHW_PicoBacteria.csv';  % manually type file name
writetable(sfmhw,filename)
