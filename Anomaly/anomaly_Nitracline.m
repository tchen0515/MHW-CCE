%%% calculate the anomalies of YJ-transformed nitracline depth (m) in each Line-Station 
clear all
close all

% import data & assort the form
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\other')
rawnitra = readtable('YJ_Nitracline.csv',VariableNamingRule="preserve")
rawnitra(:,1)=[];

%% Select Cruise and Line-Station to calculate anomalies
line=unique(rawnitra.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(rawnitra(rawnitra.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= rawnitra(rawnitra.Line==line(i)&rawnitra.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% calculate seasonal average abundance (by month
for i=1:length(line)
    stats = unique(rawnitra(rawnitra.Line==line(i),:).Station);
   for j=1:length(stats)
formatspec ='line%sstat%s'; %the line-station 
finalstat = sprintf(formatspec,num2str(line(i)*10),num2str(stats(j)*10)); 

formatspec2 ='aver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*10),num2str(stats(j)*10));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.yj_nitra(',finalstat,'.Season==mon,:)']);
if mean(aver,'omitnan')==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver,"omitnan")']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:)']);
    end
   end
end

%%% calculate anomalies in each line-station through time
anonitra=[];

for k=1:height(rawnitra)    
    m=rawnitra.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=num2str(rawnitra.Line(k)*10);
numsta=num2str(rawnitra.Station(k)*10);
%select correspondent finalaver
formatspec1='aver%s_%s';
finalmean1=sprintf(formatspec1,numline,numsta);

%calculate anomalies
        eval(['anonitra(k,:)=rawnitra.yj_nitra(k)-', finalmean1,'.("',strm,'");']);
  
end

% pull time information and anomalies together
final=[]; 
final(:,1)=rawnitra.Line;  % Temporal Information  
final(:,2)=rawnitra.Station; 
final(:,3)=rawnitra.Year;  % Saptial Information  
final(:,4)=rawnitra.Season;
final(:,5)=rawnitra.Month;  
final(:,6)=rawnitra.Day;
final(:,7)=anonitra;  % Anomaly
final=array2table(final);
final.Properties.VariableNames=["Line","Station","Year","Season","Month","Day","yj_nitracline"];

%export table
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\')
filename=['Anomaly_Nitracline.csv'];
writetable(final,filename);