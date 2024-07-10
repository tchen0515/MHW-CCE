%%% eliminate missing & unneccessary values in rawest PP (194903-202010_Bottle.csv)
clear all
close all
% import data & assort the form
cd ('...\CalCOFI\other\CalCOFI_Database_194903-202010_csv_26062023\')
raw = readtable('194903-202010_Bottle.csv',VariableNamingRule='preserve');

% eliminate missing or bas quality value
idx=find(raw.C14A1q~=9&raw.C14A1q~=9);  
ppraw=raw(idx,:);
for v=1:height(ppraw)
     if ppraw.C14As1(v)<0   
         ppraw.C14As1(v)=0;
     end
     if ppraw.C14As2(v)<0   
         ppraw.C14As2(v)=0;
     end
end

% average replication & extract the needed clomuns
C14A=[ppraw.C14As1 ppraw.C14As2];
C14A=array2table(mean(C14A,2,'omitnan')); 
C14A.Properties.VariableNames="PP"; 
cln=[1:5];
ppure=[ppraw(:,cln) C14A]; % extract smapling inofrmation & averaged PP value

% indicate station information
stats = char(ppure.Sta_ID);  %use StationID since it is more standardized than lat&long
ppure.Line = ppraw.pH1;   %creatw null columns
ppure.Station = ppraw.pH1;
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
    eval(['timedate= datetime("1-Jan-',num2str(yr),'")+',jday,'-1']) % datetime converted from Julian day
    dtime=datevec(timedate);
    month= str2double(code([6:7]));
    date=dtime(:,3);
    Tinfo(i,:)=[yr month date];
end
Tinfo=array2table(Tinfo);
Tinfo.Properties.VariableNames=["Year","Month","Day"];

%convert month into season scale
addpath '...\CalCOFI\code_CalCOFI\'
season=Tinfo.Month;
for s=1:height(season)
    season(s)=month2season(season(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

ppure=[Tinfo Season ppure]; % insert temporal information 

%export data
cd ('...\CalCOFI\Phyto')
writetable(ppure,'PP_RawFromBottle.csv')
