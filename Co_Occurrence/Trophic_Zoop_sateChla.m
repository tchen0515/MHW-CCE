%%% Write the tables of MHWOccurrence for ZooDosplacement & Chla satellite 
close all
clear all

% import Final_MHW_ZooDisplacement
cd('/nexsan/people/tchen/CalCOFI/output_mhwbio/')
zoo=readtable("v2_Final_MHW_ZooDisplace.csv","VariableNamingRule","preserve");

%import Chla anomaly
cd('/nexsan/people/tchen/CalCOFI/output_phyto/')
% load("chla_anomaly.mat") %chlaano
load("chlalog10_anomaly_workspace_240404.mat") % origianl log-transformed Chla


% select coordinate
tagetChla=zeros(height(zoo),1); %zero array to storage outptu

% Grid upper-left corner (45,-140) & lower-right corner (30.03597,-115.5454)
x1=(45-30.0397)/417; % one grid on lat scale (row) chlaana
y1=(140-115.5454)/540; % one grid on long scale (column)
lat_used=45:-0.0359:30.03597;  %flip to the normal order
lon_used=-140:0.0453:-115.5454;

for i=1:height(zoo)
% select the region covering the station 
%latitude (0.25 resolution)
targetLat = zoo(i,:).Latitude;
arr1 = lat_used; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest = arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong = zoo(i,:).Longitude;
arr2 = lon_used;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest = arr2(closetIndex2); 

targetrow=find(lat_used==Latclosest); % nearest coordinate
targetcol=find(lon_used==Longclosest);

% select date (page number) 
yr = table2array(zoo(i,"Year"));
mo = table2array(zoo(i,"Month"));
da = table2array(zoo(i,"Day"));
page=datenum(yr,mo,da)-datenum(1996,11,1)+1;
if page < 1          % make sure the sampling date is later than 1996/11/1 so that the Chla is available
    tagetChla(i,:)=nan;
else
    tagetChla(i,:)=chlalog10_ano(targetrow,targetcol,page); % no need to be flipped?
end
end

zoo.Chla=tagetChla

% export output
cd('/nexsan/people/tchen/CalCOFI/output_mhwbio/')
filename='v2_Trophic_ZooDisplace_satelliteChla.csv';
writetable(zoo,filename)

