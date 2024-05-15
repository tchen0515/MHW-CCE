%%% calculate the anomalies of YJ-transformed abundance (No*m^-2) in each Line-Station in Fish larve data
clear all
close all
% import YJ_trans_FishLarve.csv
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Fish\')
ALLbio = readtable('YJ_FishLarve1215.csv',VariableNamingRule='preserve')
ALLbio= ALLbio(:,2:end);

% elminate the sampling only coducted at certain station once
line=ALLbio.Line;
station=ALLbio.Station;
info=[line,station];
rl_sampling=unique(info,'rows'); % sort out the list of daliy sampling at each station
rl_sampling=array2table(rl_sampling);
rl_sampling.Properties.VariableNames=["Line","Station"];
for i=1:height(rl_sampling)
    idx=find(ALLbio.Line==rl_sampling.Line(i)&ALLbio.Station==rl_sampling.Station(i));
if length(idx)==1
    ALLbio.Year(idx)=0;
end
end
fegg=ALLbio(ALLbio.Year~=0,:);

% remove the station that all sampling are zeros
rl_station=unique(fegg(:,["Season" "Latitude" "Longitude"]),"rows"); % sort out the list of all stations
fegg15=fegg;
for i=1:height(rl_station)
    idx=find(fegg.Season==rl_station.Season(i)&...
        fegg.Latitude==rl_station.Latitude(i)&fegg.Longitude==rl_station.Longitude(i));
    chose_st=fegg(idx,:);
if sum(chose_st.sardine)==0  % check sardine egg number
    fegg15(idx,"sardine")=array2table(nan(length(idx),1));
    fegg15(idx,"yj_sardine")=array2table(nan(length(idx),1));
end
if sum(chose_st.anchovy)==0  % check anchovy egg number
    fegg15(idx,"anchovy")=array2table(nan(length(idx),1));
    fegg15(idx,"yj_anchovy")=array2table(nan(length(idx),1));
end
end
%elminate rows that both sardine & anchovy are NA
idx=find(isnan(fegg15.sardine)==1&isnan(fegg15.anchovy)==1);
fegg15(idx,:)=[];
bioall=fegg15;

%Select Cruise and Line-Station to calculate anomalies
line=unique(bioall.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(bioall(bioall.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= bioall(bioall.Line==line(i)&bioall.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% calculate seasonal average abundance (by month
for i=1:length(line)
    stats = unique(bioall(bioall.Line==line(i),:).Station);
   for j=1:length(stats)
formatspec ='line%sstat%s'; %the line-station 
finalstat = sprintf(formatspec,num2str(line(i)*10),num2str(stats(j)*10)); 

% sardine
formatspec2 ='saraver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*10),num2str(stats(j)*10));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.yj_sardine(',finalstat,'.Season==mon,:)']);
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

%anchovy    
    formatspec2 ='ancaver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*10),num2str(stats(j)*10));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver2=',finalstat,'.yj_anchovy(',finalstat,'.Season==mon,:)']);
if mean(aver2,'omitnan')==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver2,"omitnan")']);
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
anosar=[]; % sardine
anoanc=[]; % anchovy

for k=1:height(bioall)    
    m=bioall.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=num2str(bioall.Line(k)*10);
numsta=num2str(bioall.Station(k)*10);
%select correspondent finalaver
formatspec1='saraver%s_%s';
finalmean1=sprintf(formatspec1,numline,numsta);
formatspec2='ancaver%s_%s';
finalmean2=sprintf(formatspec2,numline,numsta);

%calculate anomalies
        eval(['anosar(k,:)=bioall.yj_sardine(k)-', finalmean1,'.("',strm,'");']);
        eval(['anoanc(k,:)=bioall.yj_anchovy(k)-', finalmean2,'.("',strm,'");']);
   
end

% pull time information and anomalies together
final=[]; 
final(:,1)=bioall.Line;  % Temporal Information  
final(:,2)=bioall.Station;
final(:,3)=bioall.Latitude;
final(:,4)=bioall.Longitude;  
final(:,5)=bioall.Year;  % Saptial Information  
final(:,6)=bioall.Season;
final(:,7)=bioall.Month;  
final(:,8)=bioall.Day;
final(:,9)=anosar;  % Anomaly
final(:,10)=anoanc;
final=array2table(final);
final.Properties.VariableNames=["Line","Station","Latitude","Longitude","Year","Season",...
    "Month","Day","yj_sardine","yj_anchovy"];


% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_zooother')
filename=['Anomaly_FishLarve1215.csv'];
writetable(final,filename);