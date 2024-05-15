%%% Write the tables of MHWOccurrence for Nitracline & Chla satellite 
close all
clear all

% import Final_MHW_nitracline
cd('/nexsan/people/tchen/CalCOFI/output_mhwbio/')
nitra=readtable('OriFinal_MHW_Nitracline.csv',"VariableNamingRule","preserve");

%import Chla anomaly
cd('/nexsan/people/tchen/CalCOFI/output_phyto/')
% load("chla_anomaly.mat") %chlaano
load("chlalog10_anomaly_workspace_240404.mat") % origianl log-transformed Chla

% select coordinate
tagetChla=zeros(height(nitra),1); %zero array to storage outptu

% Grid upper-left corner (45,-140) & lower-right corner (30.03597,-115.5454)
x1=(45-30.0397)/417; % one grid on lat scale (row) chlaana
y1=(140-115.5454)/540; % one grid on long scale (column)
lat_used=45:-0.0359:30.03597;  %flip to the normal order
lon_used=-140:0.0453:-115.5454;

for i=1:height(nitra)
% select the region covering the station 
%latitude (0.25 resolution)
targetLat = nitra(i,:).Latitude;
arr1 = lat_used; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest = arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong = nitra(i,:).Longitude;
arr2 = lon_used;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest = arr2(closetIndex2); 

targetrow=find(lat_used==Latclosest); % nearest coordinate
targetcol=find(lon_used==Longclosest);

% select date (page number) 
yr = table2array(nitra(i,"Year"));
mo = table2array(nitra(i,"Month"));
da = table2array(nitra(i,"Day"));
page=datenum(yr,mo,da)-datenum(1996,11,1)+1;
if page < 1          % make sure the sampling date is later than 1996/11/1 so that the Chla is available
    tagetChla(i,:)=nan;
else
    tagetChla(i,:)=chlalog10_ano(targetrow,targetcol,page); % no need to be flipped?
end
end

nitra.Chla=tagetChla

% export output
cd('/nexsan/people/tchen/CalCOFI/output_mhwbio/')
filename='Nitra_satelliteChla.csv';
writetable(nitra,filename)