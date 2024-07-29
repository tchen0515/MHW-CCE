%%% read hdf file (for Chla data)
close all
clear all
%function [map] = hdfchla(yr)
folder=['...'] % the folder where the raw data (https://spg-satdata.ucsd.edu/CC4km/) are downloaded 
cd(folder)
list=dir('*.hdf'); %% reading all the files one by one
% retrieve information about the contents of the HDF file.
for i = 1:length(list) 
    filehdf = list(i).name;
    fileinfo = hdfinfo(filehdf);
    dsets = fileinfo.SDS % retrieve dataset name
    chlaraw = hdfread(filehdf,dsets.Name);
% fix pixel value (see WIM website for detailed explanation)
% convert int8 to numeric values
chla = double(chlaraw); 
ncols = length(chla(1,:));
nrows = length(chla(:,1));
for r = 1:nrows  % fix all negative values
    for c = 1:ncols
        if chlaraw(r,c)< 0
           chla(r,c)=chla(r,c)+256; 
        end
    end
end
% omit invalid values
chla_clean = chla;
for r = 1:nrows  
    for c = 1:ncols
        if chla(r,c)== 0|chla(r,c)== 1|chla(r,c)== 255;
           chla_clean(r,c)= nan;
        end
    end
end
%convert pixel vlaue into Chl value,Chl (mg m-3) = 10^(0.015 * PV - 2.0)
chla_final= chla_clean;
for r = 1:nrows  
    for c = 1:ncols
        if chlaraw(r,c) ~= nan
           chla_final(r,c) = 10^(0.015*chla_clean(r,c)-2.0);
        end
    end
end
cd ('...\chla_midday\') %output directory % will be used in further steps (bind_chla.m) 
    for j=1:width(fileinfo.Attributes)
        if strcmp(fileinfo.Attributes(j).Name,'End Year')
        endyr = fileinfo.Attributes(j).Value; %end year
        elseif strcmp(fileinfo.Attributes(j).Name,'Start Day')
        stday = double(fileinfo.Attributes(j).Value); %start day
        elseif strcmp(fileinfo.Attributes(j).Name,'End Day')
        eday= double(fileinfo.Attributes(j).Value); %end day
        end
    end
    % find the median day for each cover period
    if rem(stday+eday,2)==0
        midday=num2str((stday+eday)/2)
    else
        midday=num2str(round((stday+eday)/2))
    end
    name = ['chla_',num2str(endyr),'_',midday];
    fn = [name,'.mat']; %name the file based on 'time_coverage_end'
    save(fn,'chla_final');
    cd (folder)
end
