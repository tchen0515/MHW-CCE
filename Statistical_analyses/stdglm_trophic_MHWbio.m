%%% write a table for cascading trophic interaction analysis (all four variable
% )
clear all
close all

%%% required data
% the co-occurrence of CDV sampling and satellite Chla is generated from Trophic_Zoop_sateChla.m 
% package gmregress (https://www.mathworks.com/matlabcentral/fileexchange/27918-gmregress)

% import data
cd('MHW-CCE/file/') 
mashup=readtable('table_325.csv',"VariableNamingRule","preserve"); % in situ data: https://doi.org/10.6073/pasta/be6d2547424b1f9a6da933392b3c3979 
zoosatechla = readtable("v2_Trophic_ZooDisplace_satelliteChla.csv","VariableNamingRule","preserve"); % file generated from Trophic_Zoop_sateChla.m 
mashup.ChlaLarger20um=str2double(mashup.ChlaLarger20um);
mashup.Fucoxanthin=str2double(mashup.Fucoxanthin);
mashup.IntChla=str2double(mashup.IntChla);
mashup.ZooDisplace=str2double(mashup.ZooDisplace);
mashup2=mashup(isnan(mashup.ZooDisplace)==0,:);

% combine satellite Chla into mashup
mashup2.sateChla=nan(height(mashup2),1);
for i=1:height(mashup2)
tf=find(zoosatechla.Latitude==mashup2(i,:).Latitude & zoosatechla.Longitude==mashup2(i,:).Longitude & ...
      zoosatechla.Line==mashup2(i,:).Line & zoosatechla.Station==mashup2(i,:).Station & ...
      zoosatechla.Year==mashup2(i,:).Year & zoosatechla.Month==mashup2(i,:).Month & ...
      zoosatechla.Day==mashup2(i,:).Day); %check if the time and station match
if isempty(tf)==0
   mashup2(i,:).sateChla=zoosatechla.Chla(tf) ;
end

end

for j=1:4
addpath '.../package'
if j==1  %eliminate NA values in satellite Chla
    cleantrophic=mashup2(isnan(mashup2.ChlaLarger20um)==0,:);
elseif j==2  %eliminate NA values in satellite Chla
    cleantrophic=mashup2(isnan(mashup2.IntChla)==0,:);
elseif j==3  %eliminate NA values in satellite Chla
    cleantrophic=mashup2(isnan(mashup2.Fucoxanthin)==0,:);
else
    cleantrophic=mashup2(isnan(mashup2.sateChla)==0,:);
end
% Spearman's rank coefficient
va = ["ChlaLarger20um","IntChla","Fucoxanthin","sateChla"];
eval([sprintf('food=cleantrophic.%s',va(j))]);

Zooano=cleantrophic.ZooDisplace;

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
cd ('...')
writetable(finalpara,"Oriresult_Trophic.csv") 



