%%% insert MHW magnitudes (anoSST) and MHW duration information
clear all
close all
% import data & assort the form
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\')
% list=dir('*.csv');
% raw = readtable(list(16).name,VariableNamingRule='preserve')  %change file name 
% taxa='salps';
raw = readtable('MHWOccurrence_FishLarvae1215.csv',VariableNamingRule='preserve')
% (also for export name)

% insert time vector (datetime)
for i=1:height(raw)
    raw.datetime(i,:)=datetime([raw.Year(i),raw.Month(i),raw.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= raw(raw.occurrence==1,:);

% import SST-related map
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\')
load('AVHRR_workspace_1982-2021.mat')

%%pick out the SST anomaly at corresponding time
sstano=[];
for i=1:height(sfmhw) 
sfmhw1=sfmhw(i,:)
% transfer cooridnate (raw coordinate is flipped compared to current data)
ts_x = (sfmhw1.mhw_long+140.125)/0.25;
ts_y = (sfmhw1.mhw_lat-24.875)/0.25;

% transfer date into time order
dorder=datenum(sfmhw1.datetime)-datenum(1982,1,1)+1

%pick out the MHW intensity at that certain time

sstano(i,:)=mhw_ts(ts_x,ts_y,dorder) %(lon,lat,day)

end

sfmhw.anoSST=sstano; %insert into main table

% pick out the MHW duration at certain time
rl=[];
for t=1:height(sfmhw)
    sfmhw1=sfmhw(t,:)
% pick out mhw_onset date
    onset_date = num2str(sfmhw1.mhw_onset);
    onset_yr = str2double(onset_date(1:4));
    onset_mo = str2double(onset_date(5:6));
    onset_d = str2double(onset_date(7:8));
    onset_datenum = datenum(onset_yr,onset_mo,onset_d);

% calculate the real-time duration
    rl(t,:) = datenum(sfmhw1.datetime(1))-onset_datenum+1;
end

sfmhw.rlduration=rl; %insert into main table

% export data
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
% filename=['Final_MHW_YJ_ZooScan_',taxa,'.csv'];
filename=['Final_MHW_FishLarvae1215.csv']  % manually type file name
writetable(sfmhw,filename)