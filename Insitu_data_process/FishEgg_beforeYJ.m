%%% prepare the quality-control Fish Egg data for Yeo-Johnson transformation analysis

%%%%% Required functions, table and raw data
% Fish Egg data from in situ sampling data: https://coastwatch.pfeg.noaa.gov/erddap/tabledap/erdCalCOFIcufes.html

close all
clear all

cd ('....') %data: https://coastwatch.pfeg.noaa.gov/erddap/tabledap/erdCalCOFIcufes.html
raw = readtable('CalCOFI Continuous Underway Fish-Egg Sampler.csv','VariableNamingRule','preserve'); %rawest data (not YJ-trans)
fegg=raw(2:end,[5:7 10:12 14:15]);

% extract temporal information
s_time=datevec(fegg.time,'yyyy-mm-dd THH:MM:SSZ');
e_time=datevec(fegg.stop_time,'yyyy-mm-dd THH:MM:SSZ');
s_date=array2table(s_time(:,1:3));
e_date=array2table(e_time(:,1:3));
s_date.Properties.VariableNames=["st_Year","st_Month","st_Day"];
e_date.Properties.VariableNames=["ed_Year","ed_Month","ed_Day"];
fegg1=[fegg s_date e_date];
idx=find(fegg1.st_Year==fegg1.ed_Year&fegg1.st_Month==fegg1.ed_Month&fegg1.st_Day==fegg1.ed_Day);
fegg1=fegg1(idx,:);  % eliminate the sampling cross day (we want the sampling conducted within same day)

% bin the global coordinate into 0.25 degree resolution
in=[fegg1.latitude,fegg1.longitude,...
fegg1.stop_latitude ,fegg1.stop_longitude];
for i=1:height(in)
    for j=1:4
in(i,j) = round(in(i,j) * 4)/4;   %roudn to nearest 0.25
    end
end
fegg1.latitude=in(:,1);
fegg1.longitude=in(:,2);
fegg1.stop_latitude=in(:,3);
fegg1.stop_longitude=in(:,4);

% eliminate the sampling cross grids
idx2=(find(fegg1.latitude==fegg1.stop_latitude&fegg1.longitude==fegg1.stop_longitude));
fegg2=fegg1(idx2,:); 
date=[fegg2.st_Year,fegg2.st_Month,fegg2.st_Day,fegg2.ed_Year,fegg2.ed_Month,fegg2.ed_Day];
long=[fegg2.latitude,fegg2.longitude,fegg2.stop_latitude,fegg2.stop_longitude];
info=[date,long];
rl_sampling=unique(info,'rows'); % sort out the list of daliy sampling at each station
rl_sampling=array2table(rl_sampling);
rl_sampling.Properties.VariableNames=["st_Year","st_Month","st_Day","ed_Year","ed_Month","ed_Day",...
    "st_Latitude","st_Longitude","ed_Latitude","ed_Longitude"];
sardine=zeros(height(rl_sampling),1);
anchovy=zeros(height(rl_sampling),1);
for i=1:height(rl_sampling)
%     idx=find(fegg2.st_Year==rl_sampling.st_Year(i)&fegg2.st_Month==rl_sampling.st_Month(i)&fegg2.st_Day==rl_sampling.st_Day(i)&...
%     fegg2.st_Line==rl_sampling.st_Line(i)&fegg2.st_Station==rl_sampling.st_Station(i));
    idx=find(fegg2.st_Year==rl_sampling.st_Year(i)&fegg2.st_Month==rl_sampling.st_Month(i)&fegg2.st_Day==rl_sampling.st_Day(i)&...
    fegg2.latitude==rl_sampling.st_Latitude(i)&fegg2.longitude==rl_sampling.st_Longitude(i));
    sardine(i,:)=sum(fegg2.sardine_eggs(idx));
    anchovy(i,:)=sum(fegg2.anchovy_eggs(idx));
end

% put all final parameter into one table
finalfish=rl_sampling;
finalfish.sardine=sardine;
finalfish.anchovy=anchovy;

% elminate the sampling only coducted at certain station once or the station that all
% sampling are all zeros
lat=finalfish.st_Latitude;
long=finalfish.st_Longitude;
info=[lat,long];
rl_sampling=unique(info,'rows'); % sort out the list of daliy sampling at each station
rl_sampling=array2table(rl_sampling);
rl_sampling.Properties.VariableNames=["Lat","Long"];
for i=1:height(rl_sampling)
    idx=find(finalfish.st_Latitude==rl_sampling.Lat(i)&finalfish.st_Longitude==rl_sampling.Long(i));
if length(idx)<=1
    finalfish.st_Year(idx)=0;
end
end
finalfish=finalfish(finalfish.st_Year~=0,:);


% export the table
cd('...')
filename='CleanIntegrated_FishEgg.csv';
writetable(finalfish,filename);           % use FishEgg_YJtrans.R for Yeo-Johnson transfomation
