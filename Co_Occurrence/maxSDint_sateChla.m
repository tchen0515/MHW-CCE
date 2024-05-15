% extract max SD-int for satel;ite Chla
clear all
close all

% import SST-related dataset
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\')
% load('AVHRR_workspace_1982-2021.mat') 
load('mhw_stdanomaly_240409.mat')  % SD standardized MHW intensity. Be sure to see if you are using original or SD version (mhw_ts/mhw_sdts)
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
puremhwsate = readtable('v2_MHWOccurrence_negmostChla.csv',VariableNamingRule='preserve'); %change file name

%extract max SD-int
maxsd=nan(height(puremhwsate),1);
first=datenum(1982,1,1);
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
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\OriBio-SDMHW')
writetable(puremhwsate,'OriMHWOccurrence_negmostChla.csv')
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\')
writetable(puremhwsate2,'newMHW_1982-2021_sd_south.csv')

