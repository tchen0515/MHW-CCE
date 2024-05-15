% plot CalCOFI sampling station map with mhw occurrence detection
clear all
close all
%% setting section
% Setting the region that I want to plot
latmin=29;
latmax=35.5;
lonmin=-127.5;
lonmax=-116;

% import station-coordinate chart
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\CruiseInfo\'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve')
staorder = staorder(staorder.Line>=76.7,:);

% import SST-related map
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\')
load('AVHRR_workspace_1982-2021.mat')

% transferring between CalCOFI station and coordinate of each station
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\code_CalCOFI\CalCOFILineStationMatLab\'
% station to coordinate
[latoff, lonoff] = cc2lat(90,120)  % offshore
[latin, lonin] = cc2lat(80,51)   % inshore
% coordinate to station
% [line, sta] = lat2cc(la,lo)

% transfer cooridnate (raw coordinate is flipped compared to current data)
in_x = round((lonin+140.125)/0.25);
in_y = round((latin-24.875)/0.25);
off_x = round((lonoff+140.125)/0.25);
off_y = round((latoff-24.875)/0.25);

%% plotting section
% plot basic CalCOFI region amp 
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\code_HMW\m_map'
   figure('pos',[10 10 5000 10000])
%    subplot(4,3,[1:6])
   m_proj('lambert','lon',[lonmin lonmax],'lat',[latmin latmax]);
   m_grid('box','fancy','linestyle','-','gridcolor','k','backcolor','w');  
%    m_coast('patch',[.7 1 .7],'edgecolor','none');
   m_gshhs_f('color','k'); %coastline, check m_map/data for backgorund coastline data
   m_gshhs_f('patch',[.3 .75 .2]); %coast   
   xlabel('Longitude')
   ylabel('Latitude')
   hold on

% plot sampling station 
for i=1:height(staorder)
    m_plot(staorder.("Lon (dec)")(i), staorder.("Lat (dec)")(i), 'ok','MarkerFaceColor',[0.75 0.75 0.75]);
end
hold on

% highlight inshore station (80,51)
   inshore=staorder(staorder.Line==80&staorder.Sta==51,:);
    m_plot(inshore.("Lon (dec)"), inshore.("Lat (dec)"), 'ok','MarkerFaceColor',[1 0 0]);
 hold on
% highlight offshore station (90,120)
   offshore=staorder(staorder.Line==90&staorder.Sta==120,:);
    m_plot(offshore.("Lon (dec)"), offshore.("Lat (dec)"), 'ok','MarkerFaceColor',[1 0 0]);
hold on
% label specific location (San Diego & Monterey)
    m_plot(-119.8324, 34.3985, '^k','MarkerFaceColor',[0 0 0]);
    m_text(-119.9, 34.3985+0.25,'Santa Barbara','Color','k');
    set(gca,'FontSize',16)
    m_plot(-117.1611, 32.7157, '^k','MarkerFaceColor',[0 0 0]);
    m_text(-117, 33-0.15,'San Diego','Color','k');
    set(gca,'FontSize',16)

% Visualize MHW time series detection
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\code_HMW\m_mhw1.0-master\'
figure('pos',[10 10 5000 10000])
% subplot(2,3,[1:3]);
event_line(sst_full,MHW,mclim,m90,[in_x in_y],1982,[1982 1 1],[2021 12 31]); %inshore
title ('Inshore station')

figure('pos',[10 10 5000 10000])
% subplot(2,3,[4:6]);
event_line(sst_full,MHW,mclim,m90,[off_x off_y],1982,[1982 1 1],[2021 12 31]); %offshore
title('Offshore station')


