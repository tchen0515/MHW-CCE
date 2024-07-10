%%% calculate the anomalies of YJ-transformed abundance (No*m^-2) in each Line-Station in ZooScan data
clear all
close all

% import data & assort the form
list={'Calanoid_copepod','copepoda_eucalanids','copepoda_harpacticoida','copepoda_poecilostomatoids'...
    'euphausiids','nauplii','oithona_like','pyrosomes','salp','doliolids'}; % list out all targeted taxa
for a=1:length(list)
cd ('...\CalCOFI\Zoo\yj_ZooScan')
taxa=char(string(list(a)));
eval(['raw = readtable("YJ_',taxa,'.csv",VariableNamingRule="preserve")']);
ALLbio=raw(3:height(raw),2:end);
ALLbio.Properties.VariableNames = ["Cruise","Station","Line","Cruise-mid-date","Station-date","time(PST)",...
    "DayNight","Abundance","CBiomass","YJ_abundance"];
% extract time information from cruise number
cruise=datevec(ALLbio.("Station-date"));
cruise_yr=cruise(:,1); % 'yyyy'-mm-CC
cruise_month=cruise(:,2); %yyyy-'mm'-CC
cruise_date=cruise(:,3);

% transform into table for table integration
cruise_yr=array2table(cruise_yr);
cruise_month=array2table(cruise_month);
cruise_date=array2table(cruise_date);
cruise_yr.Properties.VariableNames=["Year"];
cruise_month.Properties.VariableNames=["Month"];
cruise_date.Properties.VariableNames=["Date"];

% convert month into season scale
addpath '...\CalCOFI\code_CalCOFI\'
season=table2array(cruise_month);
for s=1:height(season)
    season(s)=month2season(season(s));
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
% formatspec1 ='line%dstat_%d' %the sampling month in this line-station 
% finalseason = sprintf(formatspec,line(i),stat80(j)) 
formatspec2 ='aver%d_%d'; %the mean abundance 
finalaver = sprintf(formatspec2,line(i),stt(j)); 
eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);
for k=1:length(finalseason)
    mon=finalseason(k);
    eval([finalaver,'(k)=mean(',finalstat,'.YJ_abundance(',finalstat,'.Season==mon,:))']);
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
for l=1:length(finalseason)
eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:)']);
    end
    end
end


%%% calculate anomalies in each line-station through time

% eval(['finalseason=',finalstat,'.Month']);
% formatspec3='anomaly%d_%d'
% finalano=sprintf(formatspec3,line(i),stt(j));
finalano=[];
for k=1:height(bioall)    
    m=bioall.Season(k);
    strm=num2str(m);
    %select correspondent finalaver
formatspec3='aver%d_%d';
finalmean=sprintf(formatspec3,bioall.Line(k),bioall.Station(k));
    %calculate anomalies
      eval(['finalano(k)=bioall.YJ_abundance(k)-', finalmean,'.("',strm,'")']); 
end

% pull time information and anomalies together
final=[]; 
final(:,1)=bioall.Year;  % Temporal Information  
final(:,2)=bioall.Month;
final(:,3)=bioall.Date;
final(:,4)=bioall.Season;  
final(:,5)=bioall.Line;  % Saptial Information  
final(:,6)=bioall.Station; 
final(:,7)=finalano;  % Anomaly
final=array2table(final);
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","Anomaly"];
% formatspec4 ='final%d_%d' % final product in one line-station 
% anofinal = sprintf(formatspec4,line(i),stt(j));
% eval([anofinal,'=final']);

% export all Cruise-LineStation-Anomalies in this file
cd('...\CalCOFI\Output\output_zooscan')
dataset='YJ_ZooScan';
filename=[dataset,'_',taxa,'.csv']; % make sure taxa is the correct name
writetable(final,filename); 
end
