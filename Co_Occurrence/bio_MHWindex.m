%%% insert MHW magnitudes (anoSST) and MHW duration information
% both MHW and bio are SD-anomaly
% manually altered part: (1)import SST dataset, (2) select SST dataset, (3) export file names and directory
clear all
close all

% import SST-related dataset
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\')
% load('AVHRR_workspace_1982-2021.mat') 
load('mhw_stdanomaly_240409.mat')  % SD standardized MHW intensity. Be sure to see if you are using original or SD version (mhw_ts/mhw_sdts)

% import data & assort the form
list={'Chla_Trapezoid','PP_Trapezoid','PicoBacteria_aver10m','HPLC','SizeFraction_113_v2',...
    'ZooDisplace','FishEgg_integrated_025grid_1215','FishLarvae1215'};  %,'negmostChla' & nitracline

for a=1:length(list)
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\')
taxa=char(string(list(a)));
 eval(['raw = readtable("v2_MHWOccurrence_',taxa,'.csv",VariableNamingRule="preserve")']) % for non-Fish related variables
% eval(['raw = readtable("MHWOccurrence_',taxa,'.csv",VariableNamingRule="preserve")']) % FishLarvae & FishEgg do not have "v2_"

% insert time vector (datetime)
for i=1:height(raw)
    raw.datetime(i,:)=datetime([raw.Year(i),raw.Month(i),raw.Day(i)]);
end

% pick out the sampling points that co-occurr with MHW
sfmhw= raw(raw.occurrence==1,:);

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

%%%%%%% be sure to see if you are using original or SD version (mhw_ts/mhw_sdts)
sstano(i,:)=mhw_sdts(ts_x,ts_y,dorder) %(lon,lat,day)   % 
%%%%%%

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
% cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\')
% filename=['Final_MHW_',taxa,'.csv']
% export SD anomaly data
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\OriBio-SDMHW\')
filename=['OriFinal_MHW_',taxa,'.csv']  % manually type file name
writetable(sfmhw,filename)
end