% plot MHW heatmap (SDIntensity~Duration, southern region only)
clear all
close all

% import data
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\'
% mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve');
mhw = readtable('newMHW_1982-2021_sd_south.csv',VariableNamingRule='preserve'); % include SD intensity & south region only

%% insert line station coverted information
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\code_CalCOFI\CalCOFILineStationMatLab'
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
[sateli, satest]=lat2cc(mhw.lat,mhw.long);
mhw.line= sateli;
mhw.station= satest;
% exclude northern region data (above 76.7)
mhw2=mhw(mhw.line>=76.7,:);

% select intensity & duration column
charmhw=array2table([mhw2.mhw_dur,mhw2.sdint_max]);   % original scale
charmhw.Properties.VariableNames=["Duration","Intensity"];
dur=charmhw.Duration;
int=charmhw.Intensity;

% define the bin edges for each characteristics
x_edges = min(int):0.01:max(int);  % 1.311:6.165
y_edges = min(dur):1:max(dur);     % 5:370

% use histogram2 to  plot heatmap-like figure
h = histogram2(int,dur,x_edges,y_edges,'DisplayStyle','tile');
colormap(jet)
cb = colorbar();
cb.Label.String = 'Event Count in Grid';
set(gca,'fontsize', 18,'FontWeight','bold');
set(gca,"XScale","log")
set(gca,"YScale","log")
xlabel("MHW SD-intensity (^oC)")
ylabel("MHW duration (days)")
xticks(1:6)
yticks([5 10 25 50 100 200 300 370])

% calculate the persentage of each value in each characteristic
% intensity
int_round=round(int,2); % round to the nearest 2 decimal digits 
frq_int=array2table(tabulate(int_round)); %calculate the persentage
frq_int.Properties.VariableNames=["Intensity","Number","Persentages"];
% sum the persentages in each intervals (0.~1,1~2,2~3...etc)
frq_int.Intensity(frq_int.Persentages==max(frq_int.Persentages)) % 1.47 degree
sum(frq_int.Persentages(frq_int.Intensity<=2)) % 61.8653% of intensity is 1~2 degree
sum(frq_int.Persentages(frq_int.Intensity>2&frq_int.Intensity<=4)) %  36.7732% of intensity is 2~4 degree
sum(frq_int.Persentages(frq_int.Intensity>4&frq_int.Intensity<=6.6)) %  1.3615 of intensity is 4~6 degree

% duration
dur_round=round(dur,2); % round to the nearest 2 decimal digits 
frq_dur=array2table(tabulate(dur_round)); %calculate the persentage
frq_dur.Properties.VariableNames=["Duration","Number","Persentages"];
% sum the persentages in each durervals (0.~1,1~2,2~3...etc)
frq_dur.Duration(frq_dur.Persentages==max(frq_dur.Persentages)) % 5 days
sum(frq_dur.Persentages(frq_dur.Duration<=10)) %  58.6514% of duration < 10 days
sum(frq_dur.Persentages(frq_dur.Duration>10&frq_dur.Duration<=100)) % 38.8817% of duration is 10~100 days
sum(frq_dur.Persentages(frq_dur.Duration>100)) %   2.4669% of duration > 100 days








