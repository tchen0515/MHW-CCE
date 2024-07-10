%%% convert raw data into depth-averaging for calculating anomalies (hplcBacteria)
close all
clear all

% import data & assort the form
cd ('...\CalCOFI\Phyto\')
raw = readtable('clean_HPLC.csv');   % dataframe generated in clean_HPLC.m. Use the new QC version
raw = raw(isnat(raw.DatetimeGMT)==0,:);
raw = raw(raw.Depth<=16,:); 
idx=find(isnan(raw.dvChla)|isnan(raw.hexfucox)|isnan(raw.Fucoxanthin)); % eliminate missing values 
raw(idx,:)=[];

%convert month into season scale
addpath '...\CalCOFI\code_CalCOFI\'
season=[];
for s=1:height(raw)
    season(s,:)=month2season(raw.Month(s));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";
% transform into table for table integration
hplc=[raw(:,1:3) Season raw(:,4:end)];

%% find out Cruise and Line-Station 
line=unique(hplc.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(hplc(hplc.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= hplc(hplc.Line==line(i)&hplc.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% extract index name (col.15~52) for further steps
para=strings(3,1);
for i=1:3
    para(i)= hplc.Properties.VariableNames{i+15}; 
end

% classify data according to sampling time
for i=1:length(line)
    stats = unique(hplc(hplc.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

%list out the sampling times
    eval(['sampletime=unique(',finalstat,'(:,1:4),"rows")']); 
    sinfo=zeros(height(sampletime),8); % null matrix for sampling information,removing unnecessary information
    bioaver =zeros(height(sampletime),3); % null matrix for average biological values

for q=1:height(sampletime)
    eval(['m_depth=find(table2array(',finalstat,'(:,1))==table2array(sampletime(q,1))&'...  % select the corresponding times (yr-m-d-season)
        'table2array(',finalstat,'(:,2))==table2array(sampletime(q,2))&'...      
        'table2array(',finalstat,'(:,3))==table2array(sampletime(q,3))&'...
        'table2array(',finalstat,'(:,4))==table2array(sampletime(q,4)))']);

% insert unique sampling information
    eval(['special=',finalstat,'(m_depth(1),:)']);
    special2=removevars(special,{'AssociatedBottleNumber','BottleNumber','CastNumber','Depth','DatetimeGMT'...
        'studyName','TotalChla','dvChla','Fucoxanthin','hexfucox'});  % remove unnecessary information
    sinfo(q,:)=table2array(special2);

% calculate average for each variables
    for p=1:length(para) 
        eval(['bioaver(q,',num2str(p),')=mean(',finalstat,'(m_depth,:).("',char(para(p)),'"))']) %variable names into para
    end
    
end
% pull the sampling information and value together 
    aa=sprintf('averfin%dst%d',line(i)*10,stats(j)*10);
    sinfo=array2table(sinfo);
    sinfo.Properties.VariableNames=["Year","Month","Day","Season","Latitude","Longitude","Line","Station"];
    bioaver=array2table(bioaver);
    bioaver.Properties.VariableNames=["dvChla","Fucoxanthin","hexfucox"];
    eval([aa,'=[sinfo bioaver]']);

end
end

% row bind all the depth averaging data
unistat=table2array(unique(hplc(:,["Line" "Station"])));  %pull out line station
aa={};
k=1;
x=array2table(zeros(2792,11));
for i=1:height(unistat)
    formatspec ='line%dstat%d'; % the line-station 
    aa{i}=sprintf('averfin%dst%d',unistat(i,1)*10,unistat(i,2)*10); 
    eval(['j=k+height(',aa{i},')']); % determine the size of each table
    eval(['x(k:j-1,:)=',aa{i}]);  % assign each subset table into correspond rows
    eval(['k=k+height(',aa{i},')']);
end
x.Properties.VariableNames=["Year","Month","Day","Season","Latitude","Longitude","Line","Station",...
    "dvChla","Fucoxanthin","hexfucox"];  

% export all Cruise-LineStation-Anomalies in this file
cd('...\CalCOFI\Phyto')
filename=['HPLC_aver16m.csv'];
writetable(x,filename);
