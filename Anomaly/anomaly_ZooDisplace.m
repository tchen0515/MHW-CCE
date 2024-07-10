%%% calculate the anomalies of log-10 scale Zooplankton Displacement volume (cm^3 per 1000m^3 Strained) 
clear all
close all
% import data & assort the form
cd ('...\CalCOFI\Zoo')
raw = readtable('195101-201607_1701-1704_1802-1804_Zoop',VariableNamingRule='preserve')
ALLbio=raw(:,[2 4:24]);
ALLbio.Properties.VariableNames = ["Cruise","StationID","Cruz_Sta","Ship_Code","Order_Occ","Cruz_Code",...
    "Line","Station","Lat_Deg","Lat_Min","Lat_Hem","Lon_Deg","Lon_Min","Lon_Hem","Tow_Type",...
    "Net_Loc","End_Time","Tow_Date","Tow_Time","Vol_StrM3","Tow_DpthM","Ttl_PVolC3"];
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
addpath '...\CalCOFI\code_CalCOFI\'
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

%% Select Cruise and Line-Station to calculate anomalies
line=unique(bioall.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(bioall(bioall.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= bioall(bioall.Line==line(i)&bioall.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat_' ,num2str(stats(j)*10),'=linestat']);
    end
end

%% calculate average abundance for each line-station
stats = unique(bioall.StationID); %use StationID since it is more standardized than lat&long
for i=1:length(stats)
    line= char(stats(i));
    numline=str2double(line(1:5))*10;
    numsta=str2double(line(7:11))*10;
    season= unique(bioall.Season(find(string(bioall.StationID)==line)));
    exstats=bioall(string(bioall.StationID)==line,:); % extract data acquired at same line-station into a seperate table

formatspec ='aver%d_%d'; % the mean abundance 
finalaver = sprintf(formatspec,numline,numsta);
eval([finalaver,'=zeros(1,length(season))']);
for k=1:length(season)
aver=exstats.Ttl_PVolC3(exstats.Season==season(k),:); %select the data sampled in same season
if mean(aver)==0
        eval([finalaver,'(:,k)=0']);    % 0 would become Inf for log-transformation
else
        eval([finalaver,'(:,k)=mean(log10(aver),"omitnan")']);
end
end

eval([finalaver,'=array2table(',finalaver,')']);
for l=1:length(season) % transfer into table
    eval([finalaver,'.Properties.VariableNames{l}=num2str(season(l))']);
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
        eval(['ano(k,:)=log10(bioall.Ttl_PVolC3(k))-', finalmean1,'.("',strm,'")']);
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
final=array2table(final); 
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station",...
        "Anomaly"];

% export all Cruise-LineStation-Anomalies in this file
cd('...\CalCOFI\Output\output_zooother')
filename=['v2_Anomaly_ZooDisplaceVol.csv'];
writetable(final,filename); 
