%%% assort HPLC raw data into the dataset for anomaly analysis
close all
clear all
% import data
cd('...\CalCOFI\Phyto')
rawhplc = readtable('Q-CCE-HPLC (Datazoo)10182023.xls','Sheet','Q-CCE-HPLC (Datazoo)') %HPLC rawest data with dateime

% eliminate bad-quality data
rawhplc = rawhplc(rawhplc.QualityControlFlag==0,:);

% insert the date information 
Date=datevec(rawhplc.DatetimeGMT)
rawhplc.Year=Date(:,1);
rawhplc.Month=Date(:,2);
rawhplc.Day=Date(:,3);

% date=NaT(height(rawhplc),1); % create null datetime array 
% for i=1:height(rawhplc)
% cruise=rawhplc.Cruise(i); %cruiseID 
% sta=rawhplc.Sta_ID(i); %station 
% tf=any(rawhplc.Cruise(i)==cast.Cruise&strcmpi(rawhplc.Sta_ID(i),cast.Sta_ID)==1&rawhplc.OrderOcc(i)==cast.Order_Occ);    %check whether the sampling is recorded
% if tf==0
%     date(i)=NaT;
% else
%     date(i)=cast.Date(find(rawhplc.Cruise(i)==cast.Cruise&strcmpi(rawhplc.Sta_ID(i),cast.Sta_ID)==1&rawhplc.OrderOcc(i)==cast.Order_Occ));
% end
% end
% rawhplc.Date=date; %insert date into main table

% extract the targeted variables' columns
hplc2=rawhplc(:,[61:63 1:10 12:13 16:17 39:40 47:48]); %, DV chla, fucoxanthin, hexanoyloxfucoxanthin

% combine data from two different labs
hplc3=hplc2;
for i=1:height(hplc2)
    if isnan(hplc2.TotalChlorophyllA_Goericke_SIO_(i))    %TotalChla
        hplc3.TotalChlorophyllA_Goericke_SIO_(i)=hplc3.TotalChlorophyllA_UMCES_(i);
    end
    if isnan(hplc2.DivinylChlorophyllA_Goericke_SIO_(i))   %DV chla
        hplc3.DivinylChlorophyllA_Goericke_SIO_(i)=hplc2.DivinylChlorophyllA_UMCES_(i);
    end
    if isnan(hplc2.Fucoxanthin_Goericke_SIO_(i))   %fucoxanthin
       hplc3.Fucoxanthin_Goericke_SIO_(i)=hplc2.Fucoxanthin_UMCES_(i); 
    end
    if isnan(hplc2.x19__hexanoyloxyfucoxanthin_Goericke_SIO_(i))   %hexanoyloxfucoxanthin
       hplc3.x19__hexanoyloxyfucoxanthin_Goericke_SIO_(i)=hplc2.x19__hexanoyloxyfucoxanthin_UMCES_(i);
    end
end

hplc3=hplc3(:,[1:13 14 16 18 20]); %remove the "backup" columns
hplc3.Properties.VariableNames(14:17)={'TotalChla','dvChla','Fucoxanthin','hexfucox'};

% export data
cd('...\CalCOFI\Phyto')
writetable(hplc3,"clean_HPLC.csv")
