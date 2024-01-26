% plot MHW heatmap (log-Intensity~log-Duration)
clear all
close all

% import data
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\'
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve');
% select intensity & duration column
charmhw=array2table([mhw.mhw_dur,mhw.int_max]);   % original scale
charmhw.Properties.VariableNames=["Duration","Intensity"];
dur=charmhw.Duration;
int=charmhw.Intensity;

% define the bin edges for each characteristics
x_edges = min(int):0.01:max(int);  % 0.72:6.6
y_edges = min(dur):1:max(dur);     % 5:370

% use histogram2 to  plot heatmap-like figure
h = histogram2(int,dur,x_edges,y_edges,'DisplayStyle','tile');
colormap(jet)
cb = colorbar();
cb.Label.String = 'Event Count in Grid';
set(gca,'fontsize', 18);
set(gca,"XScale","log")
set(gca,"YScale","log")
xlabel("MHW intensity (^oC)")
ylabel("MHW duration (days)")
xticks([1 1.5 2 2.5 3 4 5 6])
yticks([5 10 25 50 100 200 300 350])

