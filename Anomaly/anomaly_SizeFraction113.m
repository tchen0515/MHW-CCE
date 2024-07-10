%%% calculate the anomalies of log10 Chla2 concentration ratio (%) and abs values (ug*l^-1) in each Line-Station in Phyto SizeFraction data
clear all
close all
% import data & assort the form
cd ('...\CalCOFI\Phyto\')
raw = readtable('SizeFraction_113.csv',VariableNamingRule='preserve')  %accumulative sum
raw.Properties.VariableNames(5)="StationID";
raw.Properties.VariableNames(9:end)=    ["Latitude","Longtitude",...
    "TotalChla","Chla_1um","Chla_3um","Chla_8um","Chla_20um",...
    "Chlalower1um","Chla1-3um","Chla3-8um","Chla8-20um","Chlalarge20um"];

% calculate the absolute density of each size class
abs=zeros(height(raw),5);
for i=1:height(raw)
    abs(i,1)=raw.Chlalower1um(i)*raw.TotalChla(i)/100;
    abs(i,2)=raw.("Chla1-3um")(i)*raw.TotalChla(i)/100;
    abs(i,3)=raw.("Chla3-8um")(i)*raw.TotalChla(i)/100;   
    abs(i,4)=raw.("Chla8-20um")(i)*raw.TotalChla(i)/100;
    abs(i,5)=raw.Chlalarge20um(i)*raw.TotalChla(i)/100;
end
raw.absChlalower1um=abs(:,1);
raw.("absChla1-3um")=abs(:,2);
raw.("absChla3-8um")=abs(:,3);
raw.("absChla8-20um")=abs(:,4);
raw.absChlalarge20um=abs(:,5);

%eliminate negative values
tablecontent = raw{1:height(raw), 11:25}; 
tablecontent(tablecontent < 0) = NaN;
raw{1:height(raw), 11:25} = tablecontent;

% Check the data distribution (package:fitmethis)
% addpath '...\matlab&linux'
% output will indicate the rank of distribution type and show the hist polt
% X2 = fitmethis(raw.("Chla1-3um"))
% X3 = fitmethis(raw.("Chla3-8um"))
% X4 = fitmethis(raw.("Chla8-20um"))
% X5 = fitmethis(raw.Chlalarge20um)
% apply log10 transformation to all category

% extract time information from cruise number
cruise=char(raw.studyName);
cruise_ym=[]; % 'yyyy'-'mm'-CC-....
for i=1:length(raw.studyName)
   cruise_ym(i,1) = str2double(cruise(i,1:4));
   cruise_ym(i,2) = str2double(cruise(i,6:7));
end
%convert month into season scale
addpath '...\CalCOFI\code_CalCOFI\'
season=cruise_ym(:,2);
for s=1:height(season)
    season(s)=month2season(season(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

% transform into table for table integration
cruise_ym=array2table(cruise_ym);
cruise_ym.Properties.VariableNames=["Year","Month"];
sf11310=[cruise_ym Season raw];

%% calculate average abundance for each line-station
stats = unique(sf11310.StationID); %use StationID since it is more standardized than lat&long
for i=1:length(stats)
    line= char(stats(i));
    numline=str2double(line(1:5))*10;
    numsta=str2double(line(7:11))*10;
    season= unique(sf11310.Season(find(string(sf11310.StationID)==line)));
    exstats=sf11310(string(sf11310.StationID)==line,:); % extract data acquired at same line-station into a seperate table

% absChlalower1um 
formatspec1 ='aver%d_%d'; % the mean abundance 
finalaver1 = sprintf(formatspec1,numline,numsta);
eval([finalaver1,'=zeros(1,length(season))']);
for k=1:length(season)
aver0=exstats.absChlalower1um(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver0)==0
        eval([finalaver1,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver0=log10(aver0);  %log-transform the raw data
        eval([finalaver1,'(:,k)=mean(logaver0(isfinite(logaver0)),"omitnan")']);
end
end

eval([finalaver1,'=array2table(',finalaver1,')']);
for l=1:length(season)
    eval([finalaver1,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% absChla1-3um 
formatspec2 ='e1aver%d_%d'; % the mean abundance 
finalaver2 = sprintf(formatspec2,numline,numsta);
eval([finalaver2,'=zeros(1,length(season))']);
for k=1:length(season)
aver1=exstats.("absChla1-3um")(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver1)==0
        eval([finalaver2,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver1=log10(aver1);
        eval([finalaver2,'(:,k)=mean(logaver1(isfinite(logaver1)),"omitnan")']);
end
end

eval([finalaver2,'=array2table(',finalaver2,')']);
for l=1:length(season)
    eval([finalaver2,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% absChla3-8um 
formatspec3 ='e3aver%d_%d'; % the mean abundance 
finalaver3 = sprintf(formatspec3,numline,numsta);
eval([finalaver3,'=zeros(1,length(season))']);
for k=1:length(season)
aver2=exstats.("absChla3-8um")(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver2)==0
        eval([finalaver3,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver2=log10(aver2);
        eval([finalaver3,'(:,k)=mean(logaver2(isfinite(logaver2)),"omitnan")']);    
end
end

eval([finalaver3,'=array2table(',finalaver3,')']);
for l=1:length(season)
    eval([finalaver3,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% absChla8-20um 
formatspec4 ='e8aver%d_%d'; % the mean abundance 
finalaver4 = sprintf(formatspec4,numline,numsta);
eval([finalaver4,'=zeros(1,length(season))']);
for k=1:length(season)
aver3=exstats.("absChla8-20um")(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver3)==0
        eval([finalaver4,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver4=log10(aver3);
        eval([finalaver4,'(:,k)=mean(logaver4(isfinite(logaver4)),"omitnan")']);   
end
end

eval([finalaver4,'=array2table(',finalaver4,')']);
for l=1:length(season)
    eval([finalaver4,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% absChlalarge20um
formatspec5 ='e20aver%d_%d'; % the mean abundance 
finalaver5 = sprintf(formatspec5,numline,numsta);
eval([finalaver5,'=zeros(1,length(season))']);
for k=1:length(season)
aver4=exstats.absChlalarge20um(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver4)==0
        eval([finalaver5,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver5=log10(aver4);
        eval([finalaver5,'(:,k)=mean(logaver5(isfinite(logaver5)),"omitnan")']);       
end
end

eval([finalaver5,'=array2table(',finalaver5,')']);
for l=1:length(season)
    eval([finalaver5,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% Chlalower1um (%)
formatspec6 ='l1aver%d_%d'; % the mean abundance 
finalaver6 = sprintf(formatspec6,numline,numsta);
eval([finalaver6,'=zeros(1,length(season))']);
for k=1:length(season)
aver5=exstats.Chlalower1um(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver5)==0
        eval([finalaver6,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver6=log10(aver5);
        eval([finalaver6,'(:,k)=mean(logaver6(isfinite(logaver6)),"omitnan")']);     
end
end

eval([finalaver6,'=array2table(',finalaver6,')']);
for l=1:length(season)
    eval([finalaver6,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% Chla1_3um (%)
formatspec7 ='t13aver%d_%d'; % the mean abundance 
finalaver7 = sprintf(formatspec7,numline,numsta);
eval([finalaver7,'=zeros(1,length(season))']);
for k=1:length(season)
aver6=exstats.('Chla1-3um')(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver6)==0
        eval([finalaver7,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver7=log10(aver6);
        eval([finalaver7,'(:,k)=mean(logaver7(isfinite(logaver7)),"omitnan")']);      
end
end

eval([finalaver7,'=array2table(',finalaver7,')']);
for l=1:length(season)
    eval([finalaver7,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% Chla3_8um
formatspec8 ='t38aver%d_%d'; % the mean abundance 
finalaver8 = sprintf(formatspec8,numline,numsta);
eval([finalaver8,'=zeros(1,length(season))']);
for k=1:length(season)
aver7=exstats.('Chla3-8um')(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver7)==0
        eval([finalaver8,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver8=log10(aver7);
        eval([finalaver8,'(:,k)=mean(logaver8(isfinite(logaver8)),"omitnan")']);         
end
end

eval([finalaver8,'=array2table(',finalaver8,')']);
for l=1:length(season)
    eval([finalaver8,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% Chla8_20um
formatspec9 ='t820aver%d_%d'; % the mean abundance 
finalaver9 = sprintf(formatspec9,numline,numsta);
eval([finalaver9,'=zeros(1,length(season))']);
for k=1:length(season)
aver8=exstats.('Chla8-20um')(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver8)==0
        eval([finalaver9,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver9=log10(aver8);
        eval([finalaver9,'(:,k)=mean(logaver9(isfinite(logaver9)),"omitnan")']);         
end
end

eval([finalaver9,'=array2table(',finalaver9,')']);
for l=1:length(season)
    eval([finalaver9,'.Properties.VariableNames{l}=num2str(season(l))']);
end

% Chlalarge20um
formatspec10 ='b20aver%d_%d'; % the mean abundance 
finalaver10 = sprintf(formatspec10,numline,numsta);
eval([finalaver10,'=zeros(1,length(season))']);
for k=1:length(season)
aver9=exstats.Chlalarge20um(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver9)==0
        eval([finalaver10,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        logaver10=log10(aver9);
        eval([finalaver10,'(:,k)=mean(logaver10(isfinite(logaver10)),"omitnan")']);         
end
end

eval([finalaver10,'=array2table(',finalaver10,')']);
for l=1:length(season)
    eval([finalaver10,'.Properties.VariableNames{l}=num2str(season(l))']);
end
end

%calculate anomalies
ano1=[]; % absChla<1
ano2=[]; % absChla1-3um
ano3=[]; % absChla3-8um
ano4=[]; % absChla8-20um
ano5=[]; % absChla>20um
ano6=[]; % Chla<1
ano7=[]; % Chla1-3um
ano8=[]; % Chla3-8um
ano9=[]; % Chla8-20um
ano10=[]; % Chla > 20um

for k=1:height(sf11310)    
    m=sf11310.Season(k); % pick up the season of each data point first
    strm=num2str(m);
line=char(sf11310.StationID(k));
numline=str2double(line(1:5))*10;
numsta=str2double(line(7:11))*10;
%select correspondent finalaver
formatspec1='aver%d_%d';
finalmean1=sprintf(formatspec1,numline,numsta);
formatspec2='e1aver%d_%d';
finalmean2=sprintf(formatspec2,numline,numsta);
formatspec3='e3aver%d_%d';
finalmean3=sprintf(formatspec3,numline,numsta);
formatspec4='e8aver%d_%d';
finalmean4=sprintf(formatspec4,numline,numsta);
formatspec5='e20aver%d_%d';
finalmean5=sprintf(formatspec5,numline,numsta);
formatspec6='l1aver%d_%d';
finalmean6=sprintf(formatspec6,numline,numsta);
formatspec7='t13aver%d_%d';
finalmean7=sprintf(formatspec7,numline,numsta);
formatspec8='t38aver%d_%d';
finalmean8=sprintf(formatspec8,numline,numsta);
formatspec9='t820aver%d_%d';
finalmean9=sprintf(formatspec9,numline,numsta);
formatspec10='b20aver%d_%d';
finalmean10=sprintf(formatspec10,numline,numsta);


%calculate anomalies
    if sf11310.absChlalower1um(k)<=0
        ano1(k,:)=nan;  
    else
        eval(['ano1(k,:)=log10(sf11310.absChlalower1um(k))-', finalmean1,'.("',strm,'")']);
    end
    if sf11310.("absChla1-3um")(k)<=0
        ano2(k,:)=nan;  
    else
        eval(['ano2(k,:)=log10(sf11310.("absChla1-3um")(k))-', finalmean2,'.("',strm,'")']);
    end
    if sf11310.("absChla3-8um")(k)<=0
        ano3(k,:)=nan;  
    else
        eval(['ano3(k,:)=log10(sf11310.("absChla3-8um")(k))-', finalmean3,'.("',strm,'")']);
    end
    if sf11310.("absChla8-20um")(k)<=0||isnan(sf11310.("absChla8-20um")(k))
        ano4(k,:)=nan;  
    else
        eval(['ano4(k,:)=log10(sf11310.("absChla8-20um")(k))-', finalmean4,'.("',strm,'")']);
    end  
    if sf11310.("absChlalarge20um")(k)<=0
        ano5(k,:)=nan;  
    else
        eval(['ano5(k,:)=log10(sf11310.("absChlalarge20um")(k))-', finalmean5,'.("',strm,'")']);
    end
  if sf11310.Chlalower1um(k)<=0
        ano6(k,:)=nan;  
    else
        eval(['ano6(k,:)=log10(sf11310.Chlalower1um(k))-', finalmean6,'.("',strm,'")']);
  end
    if sf11310.("Chla1-3um")(k)<=0
        ano7(k,:)=nan;  
    else
        eval(['ano7(k,:)=log10(sf11310.("Chla1-3um")(k))-', finalmean7,'.("',strm,'")']);
    end  
    if sf11310.("Chla3-8um")(k)<=0
        ano8(k,:)=nan;  
    else
        eval(['ano8(k,:)=log10(sf11310.("Chla3-8um")(k))-', finalmean8,'.("',strm,'")']);
    end  
    if sf11310.("Chla8-20um")(k)<=0
        ano9(k,:)=nan;  
    else
        eval(['ano9(k,:)=log10(sf11310.("Chla8-20um")(k))-', finalmean9,'.("',strm,'")']);
    end  
    if sf11310.Chlalarge20um(k)<=0
        ano10(k,:)=nan;  
    else
        eval(['ano10(k,:)=log10(sf11310.Chlalarge20um(k))-', finalmean10,'.("',strm,'")']);
    end  
end

%% combine results into one main table
%split station ID into Line &station
stationid=char(sf11310.StationID);
for r=1:height(stationid)      %convert into numeric type
    Line(r,:)=str2double(stationid(r,1:5));
    station(r,:)=str2double(stationid(r,7:11));
end
%extract sampling date
date=datevec(raw.('Datetime GMT'));
%cloumn binding
final=[];
final(:,1)=sf11310.Year;  % Temporal Information  
final(:,2)=sf11310.Month;
final(:,3)=date(:,3);
final(:,4)=sf11310.Season;
final(:,5)=Line; % Spatial information
final(:,6)=station;
final(:,7)=ano1; %output anomalies
final(:,8)=ano2;
final(:,9)=ano3;
final(:,10)=ano4;
final(:,11)=ano5;
final(:,12)=ano6;
final(:,13)=ano7;
final(:,14)=ano8;
final(:,15)=ano9;
final(:,16)=ano10;
final=array2table(final); 
final.Properties.VariableNames=["Year","Month","Day","Season","Line","Station",...
        "absChlower1um","absChla1-3um","absChla3-8um","absChla8-20um","absChlalarge20um",...
        "Chlalower1um","Chla1-3um","Chla3-8um","Chla8-20um","Chlalarge20um"];

% export all Cruise-LineStation-Anomalies in this file
cd('...\CalCOFI\output\output_phyto')
filename=['v2_Anomaly_SizeFraction_113_v2.csv']; % do not overwrite the version 1
writetable(final,filename);

