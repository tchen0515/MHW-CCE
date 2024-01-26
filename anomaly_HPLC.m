%%% calculate the anomalies of log10 indicator (µg*l^-1) in each Line-Station in HPLC data
clear all
close all
% import data & assort the form
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Phyto\')
raw = readtable('clean_HPLC.csv');   % dataframe generated in clean_HPLC.m. Use the new QC version
raw = raw(isnat(raw.DatetimeGMT)==0,:);
raw = raw(raw.Depth<=16,:);  %only consider surface layers

% extract time information from cruise number
%convert month into season scale
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\code_CalCOFI\'
season=[];
for s=1:height(raw.Month)
    season(s,:)=month2season(raw.Month(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

hplc=[Season raw];

%% calculate average abundance for each line-station
% Select Cruise and Line-Station to calculate anomalies
line=unique(hplc.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(hplc(hplc.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= hplc(hplc.Line==line(i)&hplc.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

%%calculate average abundance in line-station (by month
for i=1:length(line)
    stats = unique(hplc(hplc.Line==line(i),:).Station);
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
        eval([finalaver,'(k)=log10(mean(aver))']);
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
        eval([finalaver,'(k)=log10(mean(aver2))']);
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
        eval([finalaver,'(k)=log10(mean(aver3))']);
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

for k=1:height(hplc)    
    m=hplc.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=hplc.Line(k)*10;
numsta=hplc.Station(k)*10;
%select correspondent finalaver
formatspec1='dvaver%d_%d';
finalmean1=sprintf(formatspec1,numline,numsta);
formatspec2='hexaver%d_%d';
finalmean2=sprintf(formatspec2,numline,numsta);
formatspec3='fucoaver%d_%d';
finalmean3=sprintf(formatspec3,numline,numsta);
%calculate anomalies
    if hplc.dvChla(k)<=0
        anodv(k,:)=nan;  
    else
        eval(['anodv(k,:)=log10(hplc.dvChla(k))-', finalmean1,'.("',strm,'")']);
    end
    if hplc.hexfucox(k)<=0
        anohex(k,:)=nan;  
    else
        eval(['anohex(k,:)=log10(hplc.hexfucox(k))-', finalmean2,'.("',strm,'")']);
    end
    if hplc.Fucoxanthin(k)<=0
        anofuco(k,:)=nan;  
    else
        eval(['anofuco(k,:)=log10(hplc.Fucoxanthin(k))-', finalmean3,'.("',strm,'")']);
    end
end

%% combine results into one main table
final=[];
final(:,1)=hplc.Year;  % Temporal Information  
final(:,2)=hplc.Month;
final(:,3)=hplc.Day;
final(:,4)=hplc.Season;
final(:,5)=hplc.Line; % Spatial information
final(:,6)=hplc.Station;
final(:,7)=anodv; %output anomalies
final(:,8)=anohex;
final(:,9)=anofuco;
final=array2table(final);
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station",...
    "dvChla","hexfucox","fucox"];

% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\output\output_phyto')
filename=['Anomaly_HPLC.csv'];
writetable(final,filename);