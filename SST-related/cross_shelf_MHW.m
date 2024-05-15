% figure out whether cross-shelf variability cause bias in MHW occurrence (reply reviewer's question)
close all
clear all
% import MHW occurrence data 
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\')
rawmhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve');
%% insert line station coverted information
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\code_CalCOFI\CalCOFILineStationMatLab'
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
[sateli, satest]=lat2cc(rawmhw.lat,rawmhw.long);
rawmhw.line= sateli;
rawmhw.station= satest;
% exclude northern region data (above 76.7)
mhw=rawmhw(rawmhw.line>=76.7,:);


%import sd-SST anomaly 
% cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\')
% load('mhw_stdanomaly_240409.mat')
% sdmhw=readtable('sd-MHWanomaly.csv',VariableNamingRule='preserve');  % the output has been storaged as seperated file
% sdmhw=sdmhw(sdmhw.SDanomaly>=0,:);

% download & simplify coastline   
coast = load('coast.mat');  % Get coastline data

%SD-anomaly: extract the points with anomaly (MHW occurrence)
% sdano=nan(length(any(mhw_sdts~=0)),3);
% sdano=readtable('sd-MHWanomaly.csv',VariableNamingRule='preserve');

% i=1;   % set up the initial value to list out the order in sdano
% for x = 1:size(mhw_sdts,1)                                             %%%change the order number
%     for y = 1:size(mhw_sdts,2)
%         for z = 1:size(mhw_sdts,3) % the sd only have one-year long
%             if mhw_sdts(x,y,z)~=0&&~isnan(mhw_sdts(x,y,z))
%                 sdano(i,1)=mhw_sdts(x,y,z); % ts_anomaly
%                 sdano(i,2)=y;    % lat
%                 sdano(i,3)=x;    % lon
%                 i=i+1;  % change the number so the next anomaly will fill into the nex row
%             end
%         end
%     end
% end


% convert grid coordinate into global coordinate
% lat=[];
% lon=[];
% for j=1:length(sdano)
%     or=find(mhw.yloc==sdano(j,2)&mhw.xloc==sdano(j,3)); % which row algins with the sdano
%     if ~isempty(or) % flip the corrdinate
%         f=or(1);
%         lat(j)=mhw.lat(f);
%         lon(j)=mhw.long(f);
%     end
% end
% 
% sdmhw=[sdano,lat',lon'];
% sdmhw=array2table(sdmhw);
% sdmhw.Properties.VariableNames={'SDanomaly','yloc','xloc','lat','lon'};
% writetable(sdmhw,'sd-MHWanomaly.csv')

% subset the dataset for plotting
% n1=1:size(mhw ,1); % original anomaly
% 0.5*length(n1)   % 209050
% y1 = randsample(n1,209050)';
% n2=1:size(sdmhw,1);  % SD anomaly
% 0.5*length(n2)   %3683242
% y2 = randsample(n2,3683242)';
% 
mhw10k=mhw;
% sdmhw10k=sdmhw(y2,:);

% Preallocate, calculate distance from shore   
coast_indexes = nan(size(mhw10k.lat));
distancefromcoast = nan(size(mhw10k.lat));
for i=1:1:size(mhw10k.lat)
    [dist, az] = distance(mhw10k.lat(i), mhw10k.long(i), coast.lat, coast.long,"degrees"); %az as spherical distances in degrees
    [distancefromcoast(i),coast_indexes(i)] = min(dist); % find the minimum
    distancefromcoast(i)=deg2km(distancefromcoast(i),'earth'); % covert unit from deg to km
end
mhw10k.distance=distancefromcoast;

% Preallocate, calculate distance from shore  (using SD-anomaly)
% sdcoast_indexes = nan(size(sdmhw10k.lat));
% sddistancefromcoast = nan(size(sdmhw10k.lat));
% for i=1:1:size(sdmhw10k.lat)
%     [sddist, sdaz] = distance(sdmhw10k.lat(i), sdmhw10k.lon(i), coast.lat, coast.long,"degrees"); %az as spherical distances in degrees
%     [sddistancefromcoast(i),sdcoast_indexes(i)] = min(sddist); % find the minimum
%     sddistancefromcoast(i)=deg2km(sddistancefromcoast(i),'earth'); % covert unit from deg to km
% end
% sdmhw10k.distance=sddistancefromcoast;


% writetable(sdmhw10k,'sd-MHWanomalyHalf.csv')

%%% use histogram2 to  plot heatmap-like figure

% (normal MHW)  
% define the bin edges for each characteristics
figure (1)
d1=mhw10k.distance;   % distance
t1=mhw10k.int_max;  % MHW intensity
x_edges = min(d1):max(d1);  % 6.2219~1895.7 (original km)
y_edges = min(t1):max(t1);  % 0.7779~5.9219  

h = histogram2(d1,t1,x_edges,y_edges,'DisplayStyle','tile');
colormap(jet)
cb = colorbar();
cb.Label.String = 'Event Count in Grid';
set(gca,'fontsize', 18);
set(gca,"XScale","log") %,'DataAspectRatio',[1 logScale/powerScale 1])
% set(gca,"YScale","log")
xlabel("Distance from shore (km)")
ylabel("MHW intensity (^oC)")
 xticks([10 100 200 500 1500])
yticks([1 2 3 4 5])
title('MHW maxInt~ DistanceFromShore')

% (SD MHW)  
% define the bin edges for each characteristics
figure (2)
d2=sdmhw10k.distance;   % distance
t2=sdmhw10k.SDanomaly;  % MHW intensity
x_edges = min(d2):max(d2);  % 6.2219~1903.4 (original km)
y_edges = min(t2):max(t2);  % -0.1631~3.4417  
logScale = diff(y_edges)/diff(x_edges);  %# Scale between the x and y ranges
powerScale = diff(log10(y_edges))/...    %# Scale between the x and y powers
             diff(log10(x_edges));
h = histogram2(d2,t2,x_edges,y_edges,'DisplayStyle','tile');
colormap(jet)
cb = colorbar();
cb.Label.String = 'Event Count in Grid';
set(gca,'fontsize', 18);
set(gca,"XScale","log") %,'DataAspectRatio',[1 logScale/powerScale 1])
% set(gca,"YScale","log")
xlabel("Distance from shore (km)")
ylabel("MHW SDanomaly (^oC/std)")
xticks([10 100 500 1000 1500])
yticks([-1 -0.1 0 1 2 3.5])
title('MHW SDInt~ DistanceFromShore')


