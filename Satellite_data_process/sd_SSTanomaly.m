%%% calculate standardized SST anomalies (i.e., anomalies at each site divided by the standard deviation of the data at each site)
% this code is modified from the codes in m_mhw1.0
close all
clear all

% load the outputs from m_mhw1.0 
cd('...')
load('AVHRR_workspace_1982-2021.mat') % outputs from m_mhw1.0/detect.m

% initial parameters set up (change the date if you use up-to-date data)
cli_start= datenum(1982,1,1);    % the duration of climatology
cli_end= datenum(2021,12,31);
ClimTime= datenum(1982,1,1):datenum(2021,12,31);
time=ClimTime;
temp=sst_full;
vWindowHalfWidth=5;
vsmoothPercentileWidth = 31;
mhw_start= datenum(1982,1,1)     % the period when you want to detect MHW occurrence
mhw_end= datenum(2021,12,31)

%%  "What if cli_start-window or cli_end+window exceeds the time range of data"
ahead_date=time(1)-(cli_start-vWindowHalfWidth);
after_date=cli_end+vWindowHalfWidth-time(end);
temp_clim=temp(:,:,ClimTime>=cli_start-vWindowHalfWidth & ClimTime<=cli_end+vWindowHalfWidth);

if ahead_date>0 && after_date>0
    temp_clim=cat(3,NaN(size(temp_clim,1),size(temp_clim,2),ahead_date), ...
    temp_clim,NaN(size(temp_clim,1),size(temp_clim,2),after_date));
elseif ahead_date>0 && after_date<=0
    temp_clim=cat(3,NaN(size(temp_clim,1),size(temp_clim,2),ahead_date), ...
    temp_clim);
elseif ahead_date<=0 && after_date>0
        temp_clim=cat(3, ...
            temp_clim,NaN(size(temp_clim,1),size(temp_clim,2),after_date));
else
    
end

temp_mhw=temp(:,:,time>=mhw_start & time<=mhw_end);

%% Calculating climatology and thresholds
date_true=datevec(cli_start-vWindowHalfWidth:cli_end+vWindowHalfWidth);
date_true=date_true(:,1:3);

date_false = date_true;
date_false(:,1) = 2012;

fake_doy = day(datetime(date_false),'dayofyear');
ind = 1:length(date_false);

stdclim=NaN(size(temp,1),size(temp,2),366);
% m90=NaN(size(temp,1),size(temp,2),366);

for i=1:366
    if i == 60
        
    else
        ind_fake=ind;
        ind_fake(fake_doy==i & ~ismember(datenum(date_true),cli_start:cli_end))=nan;
    data_thre=num2cell(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),3);

%             m90(:,:,i) = quantile(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),vThreshold,3);
            stdclim(:,:,i) = std(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),0,3,'omitnan');
            
%         case 'python'
%             
%             m90(:,:,i) = cellfun(@percentile, data_thre,repmat({vThreshold},size(temp,1),size(temp,2)));
%             mclim(:,:,i) = mean(temp_clim(:,:,any(ind_fake'>=(ind_fake(fake_doy == i)-vWindowHalfWidth) & ind_fake' <= (ind_fake(fake_doy ==i)+vWindowHalfWidth),2)),3,'omitnan');
    
    end
end
% Dealing with Feb29
% m90(:,:,60) = mean(m90(:,:,[59 61]),3,'omitnan');
stdclim(:,:,60) = std(stdclim(:,:,[59 61]),0,3,'omitnan');

% Does running averages of threshold and clim..

% m90long=smoothdata(cat(3,m90,m90,m90),3,'movmean',vsmoothPercentileWidth);
% m90=m90long(:,:,367:367+365);
stdclimlong=smoothdata(cat(3,stdclim,stdclim,stdclim),3,'movmean',vsmoothPercentileWidth);
mhw_sd=stdclimlong(:,:,367:367+365);


% divide anomalies at each site by the SD of the data at each site 
mhw_sdts = nan(size(mhw_ts));
for x = 1:size(mhw_ts,1)
    for y = 1:size(mhw_ts,2)
        for z = 1:size(mhw_ts,3) % the sd only have one-year long
            da=datenum(1982,1,1)+z-1;
            d= datetime(da, 'ConvertFrom','datenum');
            doy = day(d,'dayofyear');
            mhw_sdts(x,y,z) = mhw_ts(x,y,z)/mhw_sd(x,y,doy);
        end
    end
end
cd('...')
save("mhw_stdanomaly_240409.mat",'mhw_sd','mhw_sdts','-v7.3')


