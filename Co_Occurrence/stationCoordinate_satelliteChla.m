%%% Find the highest negative Chla anomaly for every grid in each MHW event (2024/04/09)
clear all
close all

% import MHW event table (with coordinate)
addpath '/nexsan/people/tchen/mhw/csv_mat-file/'
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve')

% import Chla anomaly
cd('/nexsan/people/tchen/CalCOFI/output_phyto/')
load("chlalog10_anomaly_workspace_240404.mat") %

% Grid of staellite Chla: upper-left corner (45,-140) & lower-right corner (30.03597,-115.5454)
x1=(45-30.0397)/417; % one grid on lat scale (row) 
y1=(140-115.5454)/540; % one grid on long scale (column)
lat_used=45:-0.0359:30.03597;  %flip to the normal order
lon_used=-140:0.0453:-115.5454;

%% find the highest negative Chla anomaly in every grid of each MHW event
negmostchla=zeros(height(mhw),1);
for i=1:height(mhw)
% select coordinate (mhw -> satellite Chla)
%latitude (0.25 resolution)
targetLat = mhw(i,:).lat;
arr1 = lat_used; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest = arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong = mhw(i,:).long;
arr2 = lon_used;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest = arr2(closetIndex2); 

targetrow=find(lat_used==Latclosest); % nearest coordinate
targetcol=find(lon_used==Longclosest);

% select time period
styr = table2array(mhw(i,"st_Year"));  % onset date
stmo = table2array(mhw(i,"st_Mon"));
stda = table2array(mhw(i,"st_Day"));
edyr = table2array(mhw(i,"end_Year")); % end date
edmo = table2array(mhw(i,"end_Mon"));
edda = table2array(mhw(i,"end_Day"));
% only consider the event occur during 1996/11/1~2020/5/13 (satellite Chla time period)
if datenum(styr,stmo,stda)<datenum(1996,11,1)
    negmostchla(i,:)=nan;
elseif datenum(edyr,edmo,edda)>datenum(2020,5,13)
    negmostchla(i,:)=nan;
else
page = datenum(styr,stmo,stda)-datenum(1996,11,1)+1:datenum(edyr,edmo,edda)-datenum(1996,11,1)+1
if any(page>8594)
    negmostchla(i,:)=nan;
else
% find the highest negative Chla anomaly
select_chla=chlalog10_ano(targetrow,targetcol,page);
if isempty(select_chla(select_chla<0))  % if only all Nan values presented
    negmostchla(i,:)=nan;
else
    negmostchla(i,:)=min(select_chla(select_chla<0));
end
% [Bymax, index] = max(abs(select_chla));
% negmostchla(i,:)=select_chla(index);  %the order of the largest Chla anomaly
end
end
end

%combine the highest negative Chla anomaly into main table
mhw2=mhw;
mhw2.Chla=negmostchla;

% export output
cd('/nexsan/people/tchen/CalCOFI/output_mhwbio/')
filename='v2_MHWOccurrence_negmostChla.csv';
writetable(mhw2,filename)

