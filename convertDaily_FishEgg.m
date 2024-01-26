%%% integrate the rows in FishEggto convert data on a daily basis
clear all
close all
% import data & assort the form
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Fish\')
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

% transfer the global coordinate into Line-Station
% addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\CruiseInfo\'
% staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve');
% 
% % select the region covering the station 
% st_line = zeros(height(fegg1),1);
% st_station= zeros(height(fegg1),1);
% ed_line = zeros(height(fegg1),1);
% ed_station= zeros(height(fegg1),1);
% 
% for i=1:height(fegg1)
% 
% %st_latitude (0.25 resolution)
% stargetLat=fegg1(i,:).latitude;
% arr1 = staorder.("Lat (dec)"); 
% [minDistance,closetIndex] = min(abs(stargetLat-arr1)); %find the order of the nearest number and its distance from target 
% stLatclosest=arr1(closetIndex); 
% 
% %st_longitude (0.25 resolution)
% sttargetLong=fegg1(i,:).longitude;
% arr2 = staorder.("Lon (dec)");  
% [minDistance2,closetIndex2] = min(abs(sttargetLong-arr2)); %find the order of the nearest number and its distance from target 
% stLongclosest=arr2(closetIndex2); 
% 
% sttargetrow=find(staorder.("Lon (dec)")==stLongclosest|staorder.("Lat (dec)")==stLatclosest); % nearest coordinate row
% stcandidate=staorder(sttargetrow,:);
% 
% if height(stcandidate)==1
%     st_line(i)=stcandidate.Line;
%     st_station(i)=stcandidate.Sta;
% end
% 
% %ed_latitude (0.25 resolution)
% edtargetLat=fegg1(i,:).stop_latitude;
% arr3 = staorder.("Lat (dec)"); 
% [minDistance3,closetIndex3] = min(abs(edtargetLat-arr3)); %find the order of the nearest number and its distance from target 
% edLatclosest=arr3(closetIndex3); 
% 
% %ed_longitude (0.25 resolution)
% edtargetLong=fegg1(i,:).stop_longitude;
% arr4 = staorder.("Lon (dec)");  
% [minDistance4,closetIndex4] = min(abs(edtargetLong-arr4)); %find the order of the nearest number and its distance from target 
% edLongclosest=arr4(closetIndex4); 
% 
% edtargetrow=find(staorder.("Lon (dec)")==edLongclosest|staorder.("Lat (dec)")==edLatclosest); % nearest coordinate row
% ed_candidate=staorder(edtargetrow,:);
% 
% if height(ed_candidate)==1
%     ed_line(i)=ed_candidate.Line;
%     ed_station(i)=ed_candidate.Sta;
% end
% end
% 
% linsta=[st_line st_station ed_line ed_station];
% linesta=array2table(linsta);
% linesta.Properties.VariableNames=["st_Line","st_Station","ed_Line","ed_Station"];
% fegg15=[fegg1 linesta];
% idx=(find(fegg15.st_Line~=0&fegg15.st_Station~=0&fegg15.ed_Line~=0&fegg15.ed_Station~=0)); % find the sampling that can match the line-station
% fegg15=fegg15(idx,:); % remove the sampling that cannot match the station cooridnate
% idx2=(find(fegg15.st_Line==fegg15.ed_Line&fegg15.st_Station==fegg15.ed_Station));
% fegg2=fegg15(idx2,:);

% integrate rows (combine samplings conducted at same day same station)
% date=[fegg2.st_Year,fegg2.st_Month,fegg2.st_Day,fegg2.ed_Year,fegg2.ed_Month,fegg2.ed_Day];
% station=[fegg2.st_Line,fegg2.st_Station,fegg2.ed_Line,fegg2.ed_Station];
% info=[date,station];
% rl_sampling=unique(info,'rows'); % sort out the list of daliy sampling at each station
% rl_sampling=array2table(rl_sampling);
% rl_sampling.Properties.VariableNames=["st_Year","st_Month","st_Day","ed_Year","ed_Month","ed_Day",...
%     "st_Line","st_Station","ed_Line","ed_Station"];
% sum the fish egg counts at same day at same station
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
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Fish\')
filename=['integrated_FishEgg_025grid_1215.csv'];
writetable(finalfish,filename);
