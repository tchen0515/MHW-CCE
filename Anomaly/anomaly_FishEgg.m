%%% calculate the anomalies of YJ-transformed number in each Line-Station in FishEgg data
clear all
close all
% import data & assort the form
cd (...\CalCOFI\Fish\')
raw = readtable('YJ_FishEgg_025grid_1215.csv') % make sure the data has been transformed in YJtrans_FishEgg.R
fishegg=raw(:,[2:4 8:9 12:15]);
fishegg.Properties.VariableNames = ["Year","Month","Day","Latitude","Longitude"...
    "sardine","anchovy","yj_sardine","yj_anchovy"];

% convert month into season scale
addpath ...\CalCOFI\code_CalCOFI\'
season=fishegg.Month;
for s=1:height(season)
    season(s)=month2season(fishegg.Month(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

fegg0=[fishegg(:,1:3) Season fishegg(:,4:end)];

% remove the station that all sampling are zeros
rl_station=unique(fegg0(:,["Season" "Latitude" "Longitude"]),"rows"); % sort out the list of all stations
fegg15=fegg0;
for i=1:height(rl_station)
    idx=find(fegg0.Season==rl_station.Season(i)&...
        fegg0.Latitude==rl_station.Latitude(i)&fegg0.Longitude==rl_station.Longitude(i));
    chose_st=fegg0(idx,:);
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
fegg=fegg15;

% % transfer the global coordinate into Line-Station
% addpath ...\CalCOFI\CruiseInfo\'
% staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve')
% 
% % select the region covering the station 
% line = zeros(height(fegg),1);
% station= zeros(height(fegg),1);
% 
% for i=1:height(fegg)
% 
% %latitude (0.25 resolution)
% targetLat=fegg(i,:).stop_latitude;
% arr1 = staorder.("Lat (dec)"); 
% [minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
% Latclosest=arr1(closetIndex); 
% 
% %longitude (0.25 resolution)
% targetLong=fegg(i,:).stop_longitude;
% arr2 = staorder.("Lon (dec)");  
% [minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
% Longclosest=arr2(closetIndex2); 
% 
% targetrow=find(staorder.("Lon (dec)")==Longclosest|staorder.("Lat (dec)")==Latclosest); % nearest coordinate row
% candidate=staorder(targetrow,:);
% if height(candidate)==1
% line(i)=candidate.Line;
% station(i)=candidate.Sta;
% end
% end
% 
% linsta=[line station];
% length(find(linsta(:,1)~=0&linsta(:,2)~=0)) % find the sampling that can match the line-station
% linesta=array2table(linsta);
% linesta.Properties.VariableNames=["Line";"Station"];
% 
% fegg=[fegg linesta];
% fegg=fegg(fegg.Station~=0,:); % remove the sampling that cannot match the station cooridnate

%% calculate average abundance for each line-station/grid
% Select Cruise and Line-Station to calculate anomalies
% line=unique(fegg.Line); %figure out how many line-station
% for i=1:length(line)   %extract rows in each line-station
%     stats = unique(fegg(fegg.Line==line(i),:).Station);
%     for j=1:length(stats)     %extract data collected in same line-station
%         linestat= fegg(fegg.Line==line(i)&fegg.Station==stats(j),:);
%         eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
%     end
% end
% Select grid to calculate anomalies
line=unique(fegg.Latitude); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(fegg(fegg.Latitude==line(i),:).Longitude);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= fegg(fegg.Latitude==line(i)&fegg.Longitude==stats(j),:);
        eval(['line',num2str(line(i)*100),'stat' ,num2str(stats(j)*-100),'=linestat']);
    end
end

%%calculate average abundance in line-station (by month
for i=1:length(line)
    stats = unique(fegg(fegg.Latitude==line(i),:).Longitude);
   for j=1:length(stats)
formatspec ='line%sstat%s'; %the line-station 
finalstat = sprintf(formatspec,num2str(line(i)*100),num2str(stats(j)*-100)); 

% sardine
formatspec2 ='saraver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*100),num2str(stats(j)*-100));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver=',finalstat,'.yj_sardine(',finalstat,'.Season==mon,:)']);
if mean(aver)==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver)']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:)']);
    end

%anchovy    
    formatspec2 ='ancaver%s_%s'; %the mean abundance 
finalaver = sprintf(formatspec2,num2str(line(i)*100),num2str(stats(j)*-100));

eval(['finalseason=unique(',finalstat,'.Season)']);
eval([finalaver,'=[]']);

for k=1:length(finalseason)
    mon=finalseason(k);
    eval(['aver2=',finalstat,'.yj_anchovy(',finalstat,'.Season==mon,:)']);
if mean(aver2)==0
        eval([finalaver,'(k)=0']);  
else
        eval([finalaver,'(k)=mean(aver2)']);
end
end
eval([finalaver,'=array2table(',finalaver,')']);
cellmon=num2str(finalseason);
    for l=1:length(finalseason)
        eval([finalaver,'.Properties.VariableNames{l}=cellmon(l,:)']);
    end

   end
end

%calculate anomalies
anosar=[]; % sardine
anoanc=[]; % anchovy

for k=1:height(fegg)    
    m=fegg.Season(k); % pick up the season of each data point first
    strm=num2str(m);
numline=num2str(fegg.Latitude(k)*100);
numsta=num2str(fegg.Longitude(k)*-100);
%select correspondent finalaver
formatspec1='saraver%s_%s';
finalmean1=sprintf(formatspec1,numline,numsta);
formatspec2='ancaver%s_%s';
finalmean2=sprintf(formatspec2,numline,numsta);

%calculate anomalies
        eval(['anosar(k,:)=fegg.yj_sardine(k)-', finalmean1,'.("',strm,'")']);
        eval(['anoanc(k,:)=fegg.yj_anchovy(k)-', finalmean2,'.("',strm,'")']);
   
end


%% combine results into one main table
final=[];
final(:,1)=fegg.Year;  % Temporal Information  
final(:,2)=fegg.Month;
final(:,3)=fegg.Day;
final(:,4)=fegg.Season;
final(:,5)=fegg.Latitude; % Spatial information
final(:,6)=fegg.Longitude;
final(:,7)=anosar; %output anomalies
final(:,8)=anoanc;
final=array2table(final);
final.Properties.VariableNames=["Year","Month","Day","Season","Latitude","Longitude",...
    "Ano_yjSardine","Ano_yjAnchovy"];

% export all Cruise-LineStation-Anomalies in this file
cd(...\CalCOFI\output\output_zooother')
filename=['Anomaly_FishEgg_integrated_025grid_1215.csv'];
writetable(final,filename);

