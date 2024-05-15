% use m.mhw code set to run satellite chla anomaly 
close all
clear all

% Before running this script, making sure you have imported the data 
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\output\output_phyto')
load('chla_log10_workspace_clean.mat')      % the one have chla_log10 (transformed)
size(sst_full); %size of data
 %lon_lat of region
cd ('/home/tchen/mhw/m_mhw1.0-master/') 
% parameters setup
time = datenum(1996,11,1):datenum(2020,5,12);
cli_start= datenum(1996,11,1)
cli_end= datenum(2020,5,12)
mhw_start= datenum(1996,11,1)
mhw_end= datenum(2020,5,12)

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


% std anomaly (NOT done, 2024/04/05)
chlalog10_sdano=nan(size(chla_log10));% the chlalog10 we want (raw-mclim NOT raw-m90)
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


%use isreal function to check the mhw_ts are all real number
% change the name of the files for differentiation
% save the worksapce for future use (log in logbook!!!)
cd ('/nexsan/people/tchen/CalCOFI/output_phyto/')
save('chlalog10_anomaly_workspace_240404','-v7.3')