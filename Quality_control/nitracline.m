%% calculate the nitraclines in each station 
clear all
close all

%import data
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\other\')
rawnitra=readtable("clean_nitra.csv");

% omit the data collected before 1982 (the start year of SST)
idx=(rawnitra.Year>=1982);
rawnitra=rawnitra(idx,:);

%% calculate the nitracline
% extract each station
line=unique(rawnitra.Line);
for i=1:length(line)   % extract rows in each line-station
    stats = unique(rawnitra(rawnitra.Line==line(i),:).Station);
    for j=1:length(stats)     % extract data collected in same line-station
        linestat= rawnitra(rawnitra.Line==line(i)&rawnitra.Station==stats(j),:);
        eval(['line',num2str(line(i)*10),'stat' ,num2str(stats(j)*10),'=linestat;']);
    end
end

% classify data according to sampling time
for i=1:length(line)
    stats = unique(rawnitra(rawnitra.Line==line(i),:).Station);

for j=1:length(stats)
    formatspec ='line%dstat%d'; %the line-station 
    finalstat = sprintf(formatspec,line(i)*10,stats(j)*10); 

%list out the sampling times
eval(['sampletime=unique(',finalstat,'(:,1:4),"rows");']); 
 sinfo=zeros(height(sampletime),6);

for q=1:height(sampletime)
    % null matrix for sampling information,removing unnecessary information
    bioaver =zeros(1,1); % null matrix for nitracline
    eval(['m_depth=find(table2array(',finalstat,'(:,1))==table2array(sampletime(q,1))&'...  % select the corresponding times (yr-m-d-season)
        'table2array(',finalstat,'(:,2))==table2array(sampletime(q,2))&'...      
        'table2array(',finalstat,'(:,3))==table2array(sampletime(q,3))&'...
        'table2array(',finalstat,'(:,4))==table2array(sampletime(q,4)))']);

% insert unique sampling information
     eval(['special=',finalstat,'(m_depth(1),:)']);
    special2=removevars(special,{'Depth_ID','Sta_ID','Depthm_m_','Nitra' });  % remove unnecessary information
     sinfo(q,:)=table2array(special2);

% find the nitracline in each station (NO3=1uM)

eval(['spp=',finalstat,'(m_depth,:);']); % extract the data collected at the same time
spp = sortrows(spp,"Depthm_m_","ascend"); % sort the depth order
% find & average duplicate values
A=spp.Depthm_m_;
[~, uniqueIdx] = unique(A);
o=setdiff( 1:numel(A), uniqueIdx );
li=nan(height(o),1);
ppl=spp.Nitra;
for d=1:length(o)
    li(d,:)=mean([ppl(o(d)) ppl(o(d)-1)]);
end

% combine the average values into table
spp.Nitra(o)=li;
spp(o-1,:)=[];
idx=find(isnan(spp.Nitra));
spp(idx,:)=[];
depths=spp.Depthm_m_;   
pp=spp.Nitra;

% omit the sampling less than 5 depth-specfic points
if length(depths)<5
    bioaver=nan;
else

    % introplation (exculding NA values)
        if any(pp>0)
            if ~any(pp>1)
                bioaver=nan;
            elseif pp(1)>=1   % if the nitracline occurred in the surface
                bioaver=0;
            else
        % if the nitracline occurred in deeper depth          
            xq=min(depths):0.1:max(depths); % the range of depths (0.1m intervel)
            ncline=interp1(depths,pp,xq)';
    % find the shallowest depth that NO3 first reached 1uM
        arr = ncline-1;
        l=1;
            while l<=length(arr)&&arr(l)<0 % find the depths closest between 1uM
                l=l+1;
            end
                closeValue= min(abs([arr(l-1) arr(l)]));
            if abs(arr)==closeValue
                closestIndex=l;
            else
                closestIndex=l-1;
            end
        rdepths=min(depths) + 0.1*(closestIndex);     % get the real number of the depth   
            bioaver=rdepths;
            end
        else
             bioaver=nan; % if all values are zeros
        end
end

% pull the sampling information and value together 
    aa=sprintf('averfin%dst%dsea%d',line(i)*10,stats(j)*10,table2array(sampletime(q,4)));
    sinfoo=array2table(sinfo(q,:));
    sinfoo.Properties.VariableNames=["Year","Month","Day","Season","Line","Station"];
    bioaver=array2table(bioaver);
    bioaver.Properties.VariableNames=["Nitracline"];
    eval([aa,'(q,:)=[sinfoo bioaver]']);
end
end
end

% row bind all the depth averaging data
unistat=table2array(unique(rawnitra(:,[4:6])));  %pull out line station
aa={};
k=1;
x=array2table(zeros(height(rawnitra),7));  %17384*7 table
for i=1:height(unistat)
    formatspec ='line%dst%dsea%d'; % the line-station 
    aa{i}=sprintf('averfin%dst%dsea%d',unistat(i,2)*10,unistat(i,3)*10,unistat(i,1)); 
    eval(['j=k+height(',aa{i},')']); % determine the size of each table
    eval(['x(k:j-1,:)=',aa{i}]);  % assign each subset table into correspond rows
    eval(['k=k+height(',aa{i},')']);
end
x.Properties.VariableNames=["Year","Month","Day","Season","Line","Station",...
    "Nitracline"];  

% Remove zero rows
x(~x.Year,:) = [];
x(isnan(x.Nitracline),:)= [];


%%export data
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\other\')
filename=['Final_nitracline.csv'];
writetable(x,filename);              % remember to do YJ-Johnson transformation
