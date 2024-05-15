%%% write a table for cascading trophic interaction analysis (all four variable
% )
clear all
close all
% import data (Final_MHW)
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\OriBio-SDMHW\')
zoo = readtable("OriFinal_MHW_ZooDisplace.csv","VariableNamingRule","preserve") % ZoopDisplace
sizephyto = readtable("OriFinal_MHW_SizeFraction_113_v2.csv","VariableNamingRule","preserve") % SizeFraction
trapechla = readtable('OriFinal_MHW_Chla_trape.csv','VariableNamingRule','preserve') % Bottle Chla
fucox = readtable("OriFinal_MHW_HPLC.csv","VariableNamingRule","preserve") % fucoxanthin 
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\'
zoosatechla = readtable("v2_Trophic_ZooDisplace_satelliteChla.csv","VariableNamingRule","preserve") % ZoopDisplace-satelliteChla, generated at COPAS hpcomputer

%exclude the sampling conducted in the northern region
zoosatechla=zoosatechla(zoosatechla.Line>=76.7,:);
zoo = zoo(zoo.Line>=76.7,:);
trapechla = trapechla(trapechla.Line>=76.7,:);

% select certain columns (check datetime,e type in raw data)
target1 = [sizephyto(:,1:8) sizephyto(:,"absChlalarge20um") sizephyto(:,"datetime")]; % >20 um Chla
target2 = [trapechla(:,3:9) trapechla(:,"datetime")]; % trape Chla
target3 = [fucox(:,[1:8 11 13 22])];

for j=1:4
    
if j==1  %Chla >20um
% select the common sampling date & station
    target=target1;
    trophic=zeros(height(target),9);

for i=1:height(target)
    tf = any(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station);
    idx = find(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station); % same date & station
  if tf==0
    trophic(i,:)= [target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),NaN,NaN,target.absChlalarge20um(i),NaN]
  else
    trophic(i,:)= [target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),...
    zoo.anoSST(idx), zoo.rlduration(idx), target.absChlalarge20um(i), zoo.Anomaly(idx)]; %combine the zoo-phyto data  
  end
end
trophic=array2table(trophic);
trophic.Properties.VariableNames=["Year","Month","Day","Line","Station",...
    "anoSST","Duration","absChlalarge20um","ZooAno"];

elseif j==2  % IntChla
    target=target2;
    trophic=zeros(height(target),9);

    for i=1:height(target)
    tf = any(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station);
    idx = find(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station); % same date & station
  if tf==0
    trophic(i,:)= [target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),NaN,NaN,target.Chla(i),NaN]
  else
    trophic(i,:)= [target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),...
    zoo.anoSST(idx), zoo.rlduration(idx), target.Chla(i), zoo.Anomaly(idx)]; %combine the zoo-phyto data  
  end
    end
    trophic=array2table(trophic);
    trophic.Properties.VariableNames=["Year","Month","Day","Line","Station",...
    "anoSST","Duration","IntChla","ZooAno"];

elseif j==3  % fucoxanthin
    target=target3;
    trophic=zeros(height(target),9);

for i=1:height(target)
    tf = any(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station);
    idx = find(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station); % same date & station
  if tf==0
    trophic(i,:)=[target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),NaN,NaN,target.fucox(i),NaN]
  else
    trophic(i,:)= [target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),...
    zoo.anoSST(idx), zoo.rlduration(idx), target.fucox(i), zoo.Anomaly(idx)]; %combine the zoo-phyto data  
  end
end
trophic=array2table(trophic);
trophic.Properties.VariableNames=["Year","Month","Day","Line","Station",...
    "anoSST","Duration","fucox","ZooAno"];
elseif j==4 %satechla
    trophic=zoosatechla(:,[3:5 7:9 21:23]);
    trophic.Properties.VariableNames=["Year","Month","Day","Line","Station",...
    "ZooAno","anoSST","Duration","Chla"];
end


% main analysis
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
cleantrophic=trophic(isnan(trophic.ZooAno)==0,:); % remove NA, which is no-overlapped sampling
if j==4  %eliminate NA values in satellite Chla
    cleantrophic=cleantrophic(isnan(cleantrophic.Chla)==0,:);
end
% spearman's rank coefficient
va = ["absChlalarge20um","IntChla","fucox","Chla"];
eval([sprintf('food=cleantrophic.%s',va(j))]);
Zooano=cleantrophic.ZooAno;

[rho1,pval1]=corr(food,Zooano,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(food,Zooano) 

%write all parameters into the table
para(j,:)=[height(Zooano),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:)];
end

para=array2table(para);
variable=array2table(["Chla>20";"IntChla";"fucoxanthin";"satelliteChla"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","Rho","pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM"];
finalpara=[finalpara(1:2,:);finalpara(4,:);finalpara(3,:)]

% export the table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(finalpara,"Oriresult_Trophic_south.csv") 

