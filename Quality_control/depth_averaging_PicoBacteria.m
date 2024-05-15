%%% convert raw data into depth-averaging for calculating anomalies (pico10Bacteria)
clear all
close all
% import data & assort the form
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Micro\')
raw = readtable('picoBacteria_194.csv',VariableNamingRule='preserve');
raw(:,16)=[];
raw.Properties.VariableNames(4)=["DatetimeUTC"];
raw.Properties.VariableNames(7:8)=["Latitude","Longitude"];
raw.Properties.VariableNames(11:15)=["Depth","HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];
idx=find(isnan(raw.Line)|isnan(raw.Station)|isnan(raw.HeteroBacteria)); 
raw(idx,:)=[];

% extract time information from Datetime
time=datevec(raw.DatetimeUTC); % year is cloumn 1,while month is column 2
cruise_ym=[];
cruise_ym(:,1)=time(:,1);
cruise_ym(:,2)=time(:,2);
cruise_ym(:,3)=time(:,3);

%convert month into season scale
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\code_CalCOFI\'
season=[];
for s=1:height(time)
    season(s,:)=month2season(time(s,2));
end
Season=array2table(season);
Season.Properties.VariableNames="Season";

% transform into table for table integration
cruise_ym=array2table(cruise_ym);
cruise_ym.Properties.VariableNames=["Year","Month","Date"];
pico=[cruise_ym Season raw];

% select sampling only in surface depths (<10m)
pico10=pico(pico.Depth<=10,:);

%% find out Cruise and Line-Station 
line=unique(pico10.Line); %figure out how many line-station
for i=1:length(line)   %extract rows in each line-station
    stats = unique(pico10(pico10.Line==line(i),:).Station);
    for j=1:length(stats)     %extract data collected in same line-station
        linestat= pico10(pico10.Line==line(i)&pico10.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat']);
    end
end

% extract index name (col.15~52) for further steps
para=strings(4,1);
for i=1:4
    para(i)= pico10.Properties.VariableNames{i+15}; 
end

% classify data according to sampling time
for i=1:length(line)
    stats = unique(pico10(pico10.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

%list out the sampling times
    eval(['sampletime=unique(',finalstat,'(:,1:4),"rows")']); 
    sinfo=zeros(height(sampletime),8); % null matrix for sampling information,removing unnecessary information
    bioaver =zeros(height(sampletime),4); % null matrix for average biological values

for q=1:height(sampletime)
    eval(['m_depth=find(table2array(',finalstat,'(:,1))==table2array(sampletime(q,1))&'...  % select the corresponding times (yr-m-d-season)
        'table2array(',finalstat,'(:,2))==table2array(sampletime(q,2))&'...      
        'table2array(',finalstat,'(:,3))==table2array(sampletime(q,3))&'...
        'table2array(',finalstat,'(:,4))==table2array(sampletime(q,4)))']);

% insert unique sampling information
    eval(['special=',finalstat,'(m_depth(1),:)']);
    special2=removevars(special,{'Assoc. Bottle Number','Bottle Number','Cruise','Depth','DatetimeUTC','Event Number'...
        'studyName','HeteroBacteria','Synechococcus','Prochlorococcus','Picoeukaryotes'});  % remove unnecessary information
    sinfo(q,:)=table2array(special2);

% calculate average for each variables
    for p=1:length(para) 
        eval(['bioaver(q,',num2str(p),')=mean(',finalstat,'(m_depth,:).("',char(para(p)),'"))']) %variable names into para
    end
    
end
% pull the sampling information and value together 
    aa=sprintf('averfin%dst%d',line(i)*10,stats(j)*10);
    sinfo=array2table(sinfo);
    sinfo.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","Latitude","Longitude"];
    bioaver=array2table(bioaver);
    bioaver.Properties.VariableNames=["HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];
    eval([aa,'=[sinfo bioaver]']);

end
end

% row bind all the depth averaging data
unistat=table2array(unique(pico10(:,9:10)));  %pull out line station
aa={};
k=1;
x=array2table(zeros(2792,12));
for i=1:height(unistat)
    formatspec ='line%dstat%d'; % the line-station 
    aa{i}=sprintf('averfin%dst%d',unistat(i,1)*10,unistat(i,2)*10); 
    eval(['j=k+height(',aa{i},')']); % determine the size of each table
    eval(['x(k:j-1,:)=',aa{i}]);  % assign each subset table into correspond rows
    eval(['k=k+height(',aa{i},')']);
end
x.Properties.VariableNames=["Year","Month","Date","Season","Line","Station","Latitude","Longitude",...
    "HeteroBacteria","Prochlorococcus","Synechococcus","Picoeukaryotes"];     

% export all Cruise-LineStation-Anomalies in this file
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Micro')
filename=['PicoBacteria_aver10m.csv'];
writetable(x,filename);
