%%% plot Fig 1 - CalCOFI sampling station map with mhw occurrence detection
clear all
close all

%%%%% Required functions, table and raw data
% Table of sampling station and corresponding coordinates: https://calcofi.org/sampling-info/station-positions/
% function cc2lat & lat2cc for converting line-station to global cooridate: https://calcofi.org/sampling-info/station-positions/2013-line-sta-algorithm/
% MHW-associated products produced by package m_mhw1.0: https://github.com/ZijieZhaoMMHW/m_mhw1.0
% package m_map for plotting global map

%% setting section
% Setting the region that I want to plot
latmin=29;
latmax=35.5;
lonmin=-127.5;
lonmax=-116;

% import station-coordinate chart
addpath '...' % https://calcofi.org/sampling-info/station-positions/
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve')
staorder = staorder(staorder.Line>=76.7,:);

% transferring between CalCOFI station and coordinate of each station
addpath '.../package' % https://calcofi.org/sampling-info/station-positions/2013-line-sta-algorithm/
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
addpath '...package/m_map'
   figure('pos',[10 10 5000 10000])
%    subplot(4,3,[1:6])
   m_proj('lambert','lon',[lonmin lonmax],'lat',[latmin latmax]);
   m_grid('box','fancy','linestyle','-','gridcolor','k','backcolor','w');  
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
addpath '...\m_mhw1.0-master\' % package m_mhw1.0
% The outputs from detect.m in package m_mhw1.0 are needed for plotting the following figures
load('sst_full.mat')
load('MHW.mat')
load('mclim.mat')
load('m90.mat')
figure('pos',[10 10 5000 10000])
% subplot(2,3,[1:3]);
event_line(sst_full,MHW,mclim,m90,[in_x in_y],1982,[1982 1 1],[2021 12 31]); %inshore
title ('Inshore station')

figure('pos',[10 10 5000 10000])
% subplot(2,3,[4:6]);
event_line(sst_full,MHW,mclim,m90,[off_x off_y],1982,[1982 1 1],[2021 12 31]); %offshore
title('Offshore station')

