%%%calculate the trapezoidal vertical integration of log10 PP (mgC*m^-2*0.5d^-1) in each Line-Station in PP data
%%% extracted PP data compiled from clean_PP.m 
close all
clear all

%import data
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Phyto')
ppure = readtable('PP_RawFromBottle.csv',VariableNamingRule='preserve'); % data generated in clean_PP.csv
% set 0-m value as 1-m value
ppure.Depthm(ppure.Depthm==0)=1;

%% vertical integration (trapezoidal)
% extract each station
line=unique(ppure.Line);
for i=1:length(line)   % extract rows in each line-station
    stats = unique(ppure(ppure.Line==line(i),:).Station);
    for j=1:length(stats)     % extract data collected in same line-station
        linestat= ppure(ppure.Line==line(i)&ppure.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat;']);
    end
end

% classify data according to sampling time
for i=1:length(line)
    stats = unique(ppure(ppure.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

%list out the sampling times
eval(['sampletime=unique(',finalstat,'(:,1:4),"rows");']); 
 sinfo=zeros(height(sampletime),6);

for q=1:height(sampletime)
    % null matrix for sampling information,removing unnecessary information
    bioaver =zeros(1,1); % null matrix for integrated PP
    eval(['m_depth=find(table2array(',finalstat,'(:,1))==table2array(sampletime(q,1))&'...  % select the corresponding times (yr-m-d-season)
        'table2array(',finalstat,'(:,2))==table2array(sampletime(q,2))&'...      
        'table2array(',finalstat,'(:,3))==table2array(sampletime(q,3))&'...
        'table2array(',finalstat,'(:,4))==table2array(sampletime(q,4)))']);

% insert unique sampling information
     eval(['special=',finalstat,'(m_depth(1),:)']);
     special2=removevars(special,{'Cst_Cnt','Btl_Cnt','Sta_ID','Depth_ID','Depthm',...
         'PP' });  % remove unnecessary information
     sinfo(q,:)=table2array(special2);

% calculate trapezoidal vertical integration

eval(['spp=',finalstat,'(m_depth,:)']); % extract the data collected at the same time
spp = sortrows(spp,"Depthm","ascend"); % sort the depth order
ex0=find(spp.Depthm~=0); % exclude 0-m records
depths=spp.Depthm(ex0,:);   
pp=spp.PP(ex0:end,:);
tf=isnan(pp);  % trapezoidal vertical integration (exculding NA values)
if tf==0
    if length(pp)>1
        bioaver=trapz(depths,pp);
    elseif length(pp)==1
        bioaver=pp;
    end
else
    bioaver=nan;
end

% pull the sampling information and value together 
    aa=sprintf('averfin%dst%dsea%d',line(i)*10,stats(j)*10,table2array(sampletime(q,4)));
    sinfoo=array2table(sinfo(q,:));
    sinfoo.Properties.VariableNames=["Year","Month","Day","Season","Line","Station"];
    bioaver=array2table(bioaver);
    bioaver.Properties.VariableNames=["PP"];
    eval([aa,'(q,:)=[sinfoo bioaver]']);
end
end
end

% row bind all the depth averaging data
unistat=table2array(unique(ppure(:,[4 11:12])));  %pull out line station
aa={};
k=1;
x=array2table(zeros(height(ppure),7));  %17384*12 table
for i=1:height(unistat)
    formatspec ='line%dst%dsea%d'; % the line-station 
    aa{i}=sprintf('averfin%dst%dsea%d',unistat(i,2)*10,unistat(i,3)*10,unistat(i,1)); 
    eval(['j=k+height(',aa{i},')']); % determine the size of each table
    eval(['x(k:j-1,:)=',aa{i}]);  % assign each subset table into correspond rows
    eval(['k=k+height(',aa{i},')']);
end
x.Properties.VariableNames=["Year","Month","Day","Season","Line","Station",...
    "PP"];     

% Remove zero rows
x(~x.Year,:) = [];

% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Phyto')
filename=['PP_VerticalInte.csv'];
writetable(x,filename);


