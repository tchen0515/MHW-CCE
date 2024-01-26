%%% check the co-occurrence of MHW and biological sampling events (PP)
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
pp = readtable('Anomaly_PP_Trapezoid.csv',VariableNamingRule='preserve')  % data generated in anomaly_PP.csv
% insert coordinate information into targeted file (station ID->coodinate)
ppnew=array2table(zeros(height(pp),width(pp)+2));
for i=1:height(pp)
        tf=any(staorder.Line==pp(i,:).Line & staorder.Sta==pp(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==pp(i,:).Line & staorder.Sta==pp(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        ppnew(i,:) = [vLat vLon pp(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        ppnew(i,:) = [vLat vLon pp(i,:)];
    end
end
ppnew.Properties.VariableNames=["Latitude","Longitude","Year","Month","Date","Season","Line","Station","PP"];

% remove sampling with unknown coordinate
ppnew(~ppnew.Latitude,:)=[];

% create columns for inseting MHW
extend=zeros(height(ppnew),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend);

% target one station for analysis
for i=1:height(ppnew)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=ppnew(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 

%longitude (0.25 resolution)
targetLong=ppnew(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(ppnew(i,"Year")) & candidate.st_Mon==table2array(ppnew(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(ppnew(i,"Year")) & candidate.st_Mon==table2array(ppnew(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(ppnew(i,"Date")) & tm.end_Day>=table2array(ppnew(i,"Date"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
                extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
                overlap=tm(tm.st_Day<=table2array(ppnew(i,"Date")) & tm.end_Day>=table2array(ppnew(i,"Date")),:);
                extend(i,1) = array2table(1); %indicated as occurrence
                extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
ppfinal=[ppnew extend];

% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
filename=['MHWOccurrence_PP_Trapezoid.csv'];
writetable(ppfinal,filename);