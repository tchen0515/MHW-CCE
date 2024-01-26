%%% check the co-occurrence of MHW and biological sampling events (Chla)
close all
clear all
% import station-coordinate chart
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\CruiseInfo\'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve')
% import MHW event table (with coordinate)
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\MHW\output\csv_mat-file\'
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve')

% import targeted file (use SizeFraction_113)
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\output\output_phyto\'
chla = readtable('Anomaly_Chla_Trapezoid.csv',VariableNamingRule='preserve')  % data generated in anomaly_Chla.csv
% insert coordinate information into targeted file (station ID->coodinate)
chlanew=array2table(zeros(height(chla),width(chla)+2));
for i=1:height(chla)
        tf=any(staorder.Line==chla(i,:).Line & staorder.Sta==chla(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==chla(i,:).Line & staorder.Sta==chla(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        chlanew(i,:) = [vLat vLon chla(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        chlanew(i,:) = [vLat vLon chla(i,:)];
    end
end
chlanew.Properties.VariableNames=["Latitude","Longitude","Year","Month","Date","Season","Line","Station","Chla"];

% remove sampling with unknown coordinate
chlanew(~chlanew.Latitude,:)=[];

% create columns for inseting MHW
extend=zeros(height(chlanew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend);

% target one station for analysis
for i=1:height(chlanew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=chlanew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=chlanew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(chlanew(i,"Year")) & candidate.st_Mon==table2array(chlanew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(chlanew(i,"Year")) & candidate.st_Mon==table2array(chlanew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(chlanew(i,"Date")) & tm.end_Day>=table2array(chlanew(i,"Date"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
                extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlachlaing MHW event 
                overlap=tm(tm.st_Day<=table2array(chlanew(i,"Date")) & tm.end_Day>=table2array(chlanew(i,"Date")),:);
                extend(i,1) = array2table(1); %indicated as occurrence
                extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
chlafinal=[chlanew extend];

% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
filename=['MHWOccurrence_Chla_Trapezoid.csv'];
writetable(chlafinal,filename);