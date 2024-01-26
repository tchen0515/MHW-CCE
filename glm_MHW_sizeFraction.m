%%% calculate the coef and glm or Geometric Mean Regression results for
%%% bio-MHW (file:SizeFraction)
close all
clear all
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
list=dir('*.csv');
puremhw = readtable('Final_MHW_SizeFraction_v2.csv',VariableNamingRule='preserve'); 

% extract variables (1) eliminate NA values
 chla1= puremhw.absChlower1um(isnan(puremhw.absChlower1um)==0); %normal
 chla2= puremhw.("absChla1-3um")(isnan(puremhw.("absChla1-3um"))==0); %normal
 chla3= puremhw.("absChla3-8um")(isnan(puremhw.("absChla3-8um"))==0); %normal
 chla4= puremhw.("absChla8-20um")(isnan(puremhw.("absChla8-20um"))==0); %normal
 chla5= puremhw.absChlalarge20um(isnan(puremhw.absChlalarge20um)==0); %normal
 chla6= puremhw.Chlalower1um(isnan(puremhw.Chlalower1um)==0);
 chla7=puremhw.("Chla1-3um")(isnan(puremhw.("Chla1-3um"))==0); %normal
 chla8= puremhw.("Chla3-8um")(isnan(puremhw.("Chla3-8um"))==0); %normal
 chla9= puremhw.("Chla8-20um")(isnan(puremhw.("Chla8-20um"))==0); %normal
 chla10= puremhw.Chlalarge20um(isnan(puremhw.Chlalarge20um)==0); %normal 

% Check the data distribution (package:fitmethis)
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
X = fitmethis(chla20);
X = fitmethis(duration); % output will indicate the rank of distribution type and show the hist polt

% Main statistical analysis part (maunally change the variable name)
for i=1:10
if i==4    %make sure the y indexes are corresponding
    intensity = puremhw.anoSST(isnan(puremhw.("absChla8-20um"))==0); % gev
    duration = puremhw.rlduration(isnan(puremhw.("absChla8-20um"))==0); % nbin
elseif i==9
    intensity = puremhw.anoSST(isnan(puremhw.("Chla8-20um"))==0); % gev
    duration = puremhw.rlduration(isnan(puremhw.("Chla8-20um"))==0); % nbin
else
     intensity = puremhw.anoSST; % gev
     duration = puremhw.rlduration; % nbin
end
eval(['ano=',sprintf('chla%d',i)]);

% intensity
[rho1,pval1]=corr(intensity,ano,'type','Spearman')  % NA has to be removed before running this command
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(intensity,ano)

% duration
% spearman's rank coefficient
[rho2,pval2]=corr(duration,ano,'type','Spearman')  % NA has to be removed before running this command
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b2,bintr2,bintjm2] = gmregress(duration,ano) 

%write all parameters into the table
para(i,:)=[height(ano),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:),rho2,pval2,b2(1),b2(2),...
    bintr2(1,:),bintr2(2,:),bintjm2(1,:),bintjm2(2,:)];
end

para=array2table(para);
variable=array2table(["absChlalow1um";"absChla1-3um";"absChla3-8um";"absChla8-20um";"absChlaLarger20um";...
"Chlalow1um";"Chla1-3um";"Chla3-8um";"Chla8-20um";"ChlaLarger20um"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

% export the table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(finalpara,"result_SizeFraction.csv")



%label the column

% regression coefficients & a matrix BINT of the given confidence intervals for B
% b=[intercept slope]
% bintr & bintjm= confidence limits of intercept & slopr computed by "Ricker" or "Jolicoeur and Mosimann" procedure

