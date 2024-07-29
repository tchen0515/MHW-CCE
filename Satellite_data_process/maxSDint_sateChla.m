% generate MHW event tables with SD-MHW intensity (one with satellite Chla and the other without satellite Chla) 
clear all
close all

% import SST-related dataset
cd ('...') 
load('mhw_stdanomaly_240409.mat')  % outputs from sd_SSTanomaly.m
cd('...')
puremhwsate = readtable('v2_MHWOccurrence_negmostChla.csv',VariableNamingRule='preserve'); % outputs from stationCoordinate_satelliteChla.m

%extract max SD-intensity
maxsd=nan(height(puremhwsate),1);
first=datenum(1982,1,1);   % the earilest date of the AVHRR-SST dataset
for i=1:height(puremhwsate)
    x=puremhwsate.xloc(i); %extract each mhw event in each grid
    y=puremhwsate.yloc(i);
    st_date=datenum(puremhwsate.st_Year(i),puremhwsate.st_Mon(i),puremhwsate.st_Day(i));
    ed_date=datenum(puremhwsate.end_Year(i),puremhwsate.end_Mon(i),puremhwsate.end_Day(i));
    st_page=st_date-datenum(1982,1,1)+1;
    ed_page=ed_date-datenum(1982,1,1)+1;
    maxsd(i)=max(mhw_sdts(x,y,st_page:ed_page));
end
puremhwsate.sdint_max=maxsd;
puremhwsate2=puremhwsate;
puremhwsate2.Chla=[];

%export table
cd('...')
writetable(puremhwsate,'OriMHWOccurrence_negmostChla.csv') % materials for composing in situ data: https://doi.org/10.6073/pasta/be6d2547424b1f9a6da933392b3c3979 
cd('...')
writetable(puremhwsate2,'newMHW_1982-2021_sd_south.csv') % later used for plotting Fig2. heatmap

