% Calculate the anomaly of log-10 transformed satellite Chla
% Adapt some syntax from m_mhw1.0 to calculate running climatology as the process to SST 
close all
clear all

% Before running this script, making sure you have imported the data 
cd ('.../output')
load('chla_log10_workspace.mat')      % the merged time-series dataset of log-10 transformed satellite Chla

% load packages m_mhw1.0 (https://github.com/ZijieZhaoMMHW/m_mhw1.0)
cd ('.../m_mhw1.0-master/') 
% parameters setup
time = datenum(1996,11,1):datenum(2020,5,12); % the start date and end date the satellite Chla dataset. Change the end date if you use up-to-date data
cli_start= datenum(1996,11,1)
cli_end= datenum(2020,5,12)
mhw_start= datenum(1996,11,1)
mhw_end= datenum(2020,5,12)

% calculate the climatology of log-10 transformed satellite Chla 
[MHW,mclim,m90,mhw_ts]=detect(chla_log10,time,cli_start,cli_end,mhw_start,mhw_end); % take about a day (~8hrs)

% After getting the outputs, the anomaly we want has to be
% calculated by ourself since the m_mhw calculates the anomaly using m90
% rather than mclim
chlalog10_ano=nan(size(chla_log10));% the chlalog10 we want (raw-mclim NOT raw-m90)
date_mhw=datevec(mhw_start:mhw_end);
indextocal = day(datetime(date_mhw),'dayofyear'); % select the correspondent dayofyear in mclim
  for i=1:size(chlalog10_ano,1)
            for j=1:size(chlalog10_ano,2)
                for k=1:size(chlalog10_ano,3) 
  mcl=mclim(i,j,indextocal(k));
  mrow=chla_log10(i,j,k);
  if ~isnan(mrow)&&~isnan(mcl)
%     chlalog10_ano(i,j,k)=nan;
%   else
      chlalog10_ano(i,j,k)=mrow-mcl;
  end
                end
            end
  end


% std anomaly 
chlalog10_sdano=nan(size(chla_log10));% the chlalog10 we want 
date_mhw=datevec(mhw_start:mhw_end);
indextocal = day(datetime(date_mhw),'dayofyear'); % select the correspondent dayofyear in mclim
  for i=1:size(chlalog10_sdano,1)
            for j=1:size(chlalog10_sdano,2)
                for k=1:size(chlalog10_asdno,3) 
%   sdmcl=mclim(i,j,indextocal(k));
  sdmrow=chla_log10(i,j,k);
  if ~isnan(sdmrow)&&~isnan(sdmcl)
%     chlalog10_ano(i,j,k)=nan;
%   else
      chlalog10_sdano(i,j,k)=sdmrow-sdmcl;
  end
                end
            end
  end

% save the worksapce 
cd ('.../output/')
save('chlalog10_anomaly_workspace_240404','-v7.3')
