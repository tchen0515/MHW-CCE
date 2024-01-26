%%% calculate the coef and glm or Geometric Mean Regression results for bio-MHW
%%% bio-MHW (file:HPLC & HPLC-ratio)
close all
clear all
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
list=dir('*.csv');
puremhw = readtable('Final_MHW_HPLC.csv',VariableNamingRule='preserve'); %change file name
puremhwratio = readtable('Final_MHW_HPLC_ratio.csv',VariableNamingRule='preserve'); %change file name


% extract variables
hplc1=puremhw.dvChla(isnan(puremhw.dvChla)==0); %normal
hplc2=puremhw.fucox(isnan(puremhw.fucox)==0); %normal
hplc3=puremhw.hexfucox(isnan(puremhw.hexfucox)==0); %normal
hplc4=puremhwratio.dvChla(isnan(puremhwratio.dvChla)==0);  %normal 
hplc5=puremhwratio.fucox(isnan(puremhwratio.fucox)==0);  %normal
hplc6=puremhwratio.hexfucox(isnan(puremhwratio.hexfucox)==0);  %normal


% Check the data distribution (package:fitmethis)
% addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
% X = fitmethis(fucoratio);
% X = fitmethis(duration); % output will indicate the rank of distribution type and show the hist polt

% Main statistical analysis part (maunally change the variable name)
for i=1:6
if i==1    %make sure the y indexes are corresponding
     intensity = puremhw.anoSST(isnan(puremhw.dvChla)==0); % gev
     duration = puremhw.rlduration(isnan(puremhw.dvChla)==0); % nbin
elseif i==2||i==3
     intensity = puremhw.anoSST; % gev
     duration = puremhw.rlduration; % nbin
elseif i==4 
     intensity = puremhwratio.anoSST(isnan(puremhwratio.dvChla)==0); % gev
     duration = puremhwratio.rlduration(isnan(puremhwratio.dvChla)==0); % nbin
else
     intensity = puremhwratio.anoSST; % gev
     duration = puremhwratio.rlduration; % nbin
end
eval(['ano=',sprintf('hplc%d',i)]);

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
variable=array2table(["DivinylChla";"Fucoxanthin";"Hexanoyloxyfucoxanthin";...
"ratioDivinylChla";"ratioFucoxanthin";"ratioHexanoyloxyfucoxanthin"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

% export the table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(finalpara,"result_HPLC.csv") 



% regression coefficients & a matrix BINT of the given confidence intervals for B
% b=[intercept slope]
% bintr & bintjm= confidence limits of intercept & slopr computed by "Ricker" or "Jolicoeur and Mosimann" procedure
