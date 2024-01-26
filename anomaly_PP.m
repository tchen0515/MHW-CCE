%%%calculate the anomalies of log10 PP (mgC*m^-2*0.5d^-1) in each Line-Station 
clear all
close all
% import data & assort the form
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Phyto\')
raw = readtable('PP_VerticalInte.csv',VariableNamingRule='preserve'); % data generated in TLintegrate_PP.csv
raw= raw(find(raw.Year~=0),:);
% eliminate missing values
idx=find(isnan(raw.PP)); 
raw(idx,:)=[];
pp21=raw;

%% Select Cruise and Line-Station to calculate anomalies
line=unique(pp21.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(pp21(pp21.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= pp21(pp21.Line==line(i)&pp21.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

%%calculate average abundance in line-station (by month
for i=1:length(line)
    stats = unique(pp21(pp21.Line==line(i),:).Station);
   for j=1:length(stats)
formatspec ='line%dstat%d'; %the line-station 
finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

formatspec2 ='aver%d_%d'; %the mean abundance 
finalaver = sprintf(formatspec2,line(i)*10,stats(j)*10);

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.PP(',finalstat,'.Season==mon,:)']);
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
   end
end

% calculate anomalies
finalano=[];
for k=1:height(pp21)    
    m=pp21.Season(k);
    %select correspondent finalaver
formatspec3='aver%d_%d';
finalmean=sprintf(formatspec3,pp21.Line(k)*10,pp21.Station(k)*10);
    %calculate anomalies
    if pp21.PP(k)==0
      finalano(k,:)=nan;  
    else
    eval(['finalano(k,:)=log10(pp21.PP(k))-', finalmean,'.("',num2str(m),'")']); 
    end
end

%% combine results into one main table
%cloumn binding
final=[];
final(:,1)=pp21.Year;  % Temporal Information  
final(:,2)=pp21.Month;
final(:,3)=pp21.Day;
final(:,4)=pp21.Season;
final(:,5)=pp21.Line; % Spatial information
final(:,6)=pp21.Station;
final(:,7)=finalano;
final=array2table(final); 
final.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","PP"];

%export table
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_phyto\')
filename=['Anomaly_PP_Trapezoid.csv'];
writetable(final,filename);
