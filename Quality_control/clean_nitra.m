%% eliminate missing & unneccessary values in rawest nutrient 
clear all
close all

% import data
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\other\')
raw=readtable('CalCOFI Bottle Data (1970 - 2021).xlsx','Sheet','in');

%% extract the NO3 information

% eliminate missing or bas quality value
idx=find(raw.NO3q~=9);  
ppraw=raw(idx,:);
for v=1:height(ppraw)
    if ppraw.NO3uM___mol_L_(v)<0  
        ppraw.NO3uM___mol_L_(v)=0;
    end
end

% average replication & extract the needed clomuns
Nit=array2table(ppraw.NO3uM___mol_L_);
Nit.Properties.VariableNames="Nitra"; 
cln=[4 5 6];
ppure=[ppraw(:,cln) Nit]; % extract smapling inofrmation & averaged Chla value

% indicate station information
stats = char(ppure.Sta_ID);  %use StationID since it is more standardized than lat&long
ppure.Line = ppraw.Depthm_m_;   %creatw null columns
ppure.Station = ppraw.Depthm_m_;
for i=1:height(ppure)
    ppure.Line(i) = str2double(stats(i,1:5));
    ppure.Station(i) = str2double(stats(i,7:11));
end

% indicate smapling time information
Tinfo=[];
for i=1:height(ppure)
    code=char(ppure.Depth_ID(i));
    yr= str2double(code([1:2 4:5])); %year
    jday=code([14:16]); % Julian day
    eval(['timedate= datetime("1-Jan-',num2str(yr),'")+',jday,'-1;']) % datetime converted from Julian day
    dtime=datevec(timedate);
    month= str2double(code([6:7]));
    date=dtime(:,3);
    Tinfo(i,:)=[yr month date];
end
Tinfo=array2table(Tinfo);
Tinfo.Properties.VariableNames=["Year","Month","Day"];

%convert month into season scale
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\code_CalCOFI\'
season=Tinfo.Month;
for s=1:height(season)
    season(s)=month2season(season(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";
% put all information together
cnitra=[Tinfo Season ppure(:,5:6) ppure(:,1:4)]

%%export data
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\other\')
writetable (cnitra,"clean_nitra.csv")