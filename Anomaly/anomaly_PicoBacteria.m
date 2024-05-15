%%% calculate the anomalies of log10 abundance (ug*l^-1) in each Line-Station in PicoBacteria data
% last updated: 3/29/24
clear all
close all
% import data & assort the form
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Micro\')
raw = readtable('PicoBacteria_aver10m.csv',VariableNamingRule='preserve'); % dataframe generated in depth_averaging_PicoBacteria.m 
% raw.Properties.VariableNames(4)=["DatetimeUTC"];
% raw.Properties.VariableNames(7:8)=["Latitude","Longitude"];
% raw.Properties.VariableNames(12:15)=["HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];
idx=find(isnan(raw.Line)|isnan(raw.Station)|isnan(raw.HeteroBacteria)); 
raw(idx,:)=[];

% extract time information from Datetime
% time=datevec(raw.DatetimeUTC); % year is cloumn 1,while month is column 2
% cruise_ym=[];
% cruise_ym(:,1)=time(:,1);
% cruise_ym(:,2)=time(:,2);
% cruise_ym(:,3)=time(:,3);

%convert month into season scale
% addpath 'C:\Users\USER\OneDrive - Florida State University\CalCOFI\code_CalCOFI\'
% season=[];
% for s=1:height(time)
%     season(s,:)=month2season(time(s,2));
% end
% Season=array2table(season);
% Season.Properties.VariableNames="Season";

% transform into table for table integration
% cruise_ym=array2table(cruise_ym);
% cruise_ym.Properties.VariableNames=["Year","Month","Date"];
pico=raw %[cruise_ym Season raw];

%% Select Cruise and Line-Station to calculate anomalies
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
    para(i)= pico.Properties.VariableNames{i+8} 
end

%% calculate average abundance in line-station (by season
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
        eval([finalaver,'(k)=mean(logaver1(isfinite(logaver1)),"omitnan")']);
end
end

eval([finalaver,'=array2table(',finalaver,')']);
for l=1:length(finalseason)
    eval([finalaver,'.Properties.VariableNames{l}=num2str(finalseason(l))']);
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
        eval(['ano',num2str(p),'(k,:)=log10(selectmicro(k))-', finalaver,'.("',strm,'")']);
end
end
end

%% combine results into one main table
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
    eval(['final(:,p+8)=ano',num2str(p)]); 
end
final=array2table(final); 
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","Latitude","Longitude",...
    "HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];
% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\USER\OneDrive - Florida State University\CalCOFI\Output\output_micro')
filename=['v2_Anomaly_PicoBacteria_aver10m.csv'];
writetable(final,filename);