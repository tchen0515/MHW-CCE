%%% check the co-occurrence of MHW and biological sampling events (SizeFraction_113)
close all
clear all
% import station-coordinate chart
addpath 'C:\Users\USER\OneDrive - Florida State University\CalCOFI\CruiseInfo\'
staorder = readtable('CalCOFIStationOrder.csv',VariableNamingRule='preserve')
% import MHW event table (with coordinate)
addpath 'C:\Users\USER\OneDrive - Florida State University\MHW\output\csv_mat-file\'
mhw = readtable('newMHW_1982-2021.csv',VariableNamingRule='preserve')

% import targeted file (use SizeFraction_113)
addpath 'C:\Users\USER\OneDrive - Florida State University\CalCOFI\output\output_phyto\'
sf113 = readtable('v2_Anomaly_SizeFraction_113_v2.csv',VariableNamingRule='preserve') % dataframe generate by (std)anomaly_SizeFraction113.m. 
 
% insert coordinate information into targeted file (station->coodinate)
sff113new=array2table(zeros(height(sf113),width(sf113)+2));
for i=1:height(sf113)
        tf=any(staorder.Line==sf113(i,:).Line & staorder.Sta==sf113(i,:).Station);
    if tf==1
        rownum(i) = find(staorder.Line==sf113(i,:).Line & staorder.Sta==sf113(i,:).Station);
        coord = staorder(rownum(i),:);
        vLat = array2table(coord.("Lat (dec)"),'VariableNames',{'Lat'});
        vLon = array2table(coord.("Lon (dec)"),'VariableNames',{'Lon'});
        sff113new(i,:) = [vLat vLon sf113(i,:)];
    else
        vLat = array2table(0,'VariableNames',{'Lat'});
        vLon = array2table(0,'VariableNames',{'Lon'});
        sff113new(i,:) = [vLat vLon sf113(i,:)];
    end
end
sff113new.Properties.VariableNames=["Latitude","Longitude","Year","Month","Day","Season","Line","Station",...
        "absChlower1um","absChla1-3um","absChla3-8um","absChla8-20um","absChlalarge20um",...
        "Chlalower1um","Chla1-3um","Chla3-8um","Chla8-20um","Chlalarge20um"];
% create columns for inseting MHW
extend=zeros(height(sff113new),10); %occurrence(Y/N)+MHW properity
extend=array2table(extend)

% target one station for analysis
for i=1:height(sff113new)

% select the region covering the station 
%latitude (0.25 resolution)
targetLat=sff113new(i,:).Latitude;
arr1 = mhw.lat; 
[minDistance,closetIndex] = min(abs(targetLat-arr1)); %find the order of the nearest number and its distance from target 
Latclosest=arr1(closetIndex); 
% if Latclosest>targetLat  %find to define the range
%    Latclosest2 = Latclosest-0.25
% else
%    Latclosest2 = Latclosest+0.25
% end

%longitude (0.25 resolution)
targetLong=sff113new(i,:).Longitude;
arr2 = mhw.long;  
[minDistance2,closetIndex2] = min(abs(targetLong-arr2)); %find the order of the nearest number and its distance from target 
Longclosest=arr2(closetIndex2); 
% if Longclosest>targetLong  %find to define the range
%    Longclosest2 = targetLong-0.25
% else
%    Longclosest2 = targetLong+0.25
% end

targetrow=find(mhw.long==Longclosest&mhw.lat==Latclosest); % nearest coordinate 
candidate=mhw(targetrow,:);
% targetrow2=find(mhw.long==Longclosest2&mhw.lat==Latclosest); % adjacent coordinate (modified Long)
% c2=mhw(targetrow2,:);
% targetrow3=find(mhw.long==Longclosest&mhw.lat==Latclosest2); % adjacent coordinate (modified Lat)
% c3=mhw(targetrow3,:);
% candidate=[c1;c2;c3];

% check whether the sampling time and the MHW occurrence match & pick out the correspond MHW event
tf=any(candidate.st_Year==table2array(sff113new(i,"Year")) & candidate.st_Mon==table2array(sff113new(i,"Month"))); %check if the year and month match
    if tf == 0 % if match, select the period of onset< date < end
     extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
    else
        % select the rows that reach the criteria
        tm=candidate(candidate.st_Year==table2array(sff113new(i,"Year")) & candidate.st_Mon==table2array(sff113new(i,"Month")),:);      
        if height(tm)==0
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence
        else
           tf2=any(tm.st_Day<=table2array(sff113new(i,"Day")) & tm.end_Day>=table2array(sff113new(i,"Day"))); % select the occurrence event covering sampling time 
            if tf2 == 0 
            extend(i,:)=array2table(zeros(1,10)); % indicated as no occurrence 
            else % there is overlapping MHW event 
            overlap=tm(tm.st_Day<=table2array(sff113new(i,"Day")) & tm.end_Day>=table2array(sff113new(i,"Day")),:);
            extend(i,1) = array2table(1); %indicated as occurrence
            extend(i,2:end) =overlap(:,[7:13 16:17]); % pull those wanted rows as a table           
            end
        end 
    end
end

% combine MHW co-occurrence with raw biological anomalies
extend.Properties.VariableNames=["occurrence","mhw_onset","mhw_end","mhw_dur","int_max","int_mean",...
    "int_var","int_cum","mhw_long","mhw_lat"];
sff113final=[sff113new extend];
% mhwbio1=sff113final(sff113final.occurrence==1,:); %if you want to know
% which rows has MHW occurrence

% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\USER\OneDrive - Florida State University\CalCOFI\output\output_mhwbio')
filename=['v2_MHWOccurrence_SizeFraction_113_v2.csv']; %alter the "std" if you run for original anomaly
writetable(sff113final,filename);



