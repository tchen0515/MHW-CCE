%%% calculate the coef and glm or Geometric Mean Regression results for bio-MHW
%%% bio-MHW (file:satelliteChla, IntChla, IntPP)
close all
clear all
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
list=dir('*.csv');
puremhwsate = readtable('MHWOccurrence_negmostChla.csv',VariableNamingRule='preserve'); %change file name
puremhwpp = readtable('Final_MHW_PP_trape.csv',VariableNamingRule='preserve'); %change file name
puremhwchla = readtable('Final_MHW_Chla_trape.csv',VariableNamingRule='preserve'); %change file name

% extract variables
phyto1=puremhwsate.Chla(isnan(puremhwsate.Chla)==0); %normal
phyto2=puremhwchla.Chla(isnan(puremhwchla.Chla)==0); %normal
phyto3=puremhwpp.PP(isnan(puremhwpp.PP)==0); %normal

% Check the data distribution (package:fitmethis)
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
% X = fitmethis(phyto1);
% X = fitmethis(duration); % output will indicate the rank of distribution type and show the hist polt

% Main statistical analysis part (maunally change the variable name)
for i=1:3
if i==1    %make sure the y indexes are corresponding,satellite
     intensity = puremhwsate.int_max(isnan(puremhwsate.Chla)==0); % gev
     duration = puremhwsate.mhw_dur(isnan(puremhwsate.Chla)==0); % nbin
elseif i==2 %IntChla
     intensity = puremhwchla.anoSST(isnan(puremhwchla.Chla)==0); % gev
     duration = puremhwchla.rlduration(isnan(puremhwchla.Chla)==0); % nbin
elseif i==3 %IntPP
     intensity = puremhwpp.anoSST(isnan(puremhwpp.PP)==0); % gev
     duration = puremhwpp.rlduration(isnan(puremhwpp.PP)==0); % nbin
end
eval(['ano=',sprintf('phyto%d',i)]);

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
variable=array2table(["satelliteChla";"VerIntChla";"VerIntPP"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

% export the table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(finalpara,"result_Bottle&Satellite_negmost.csv")


% regression coefficients & a matrix BINT of the given confidence intervals for B
% b=[intercept slope]
% bintr & bintjm= confidence limits of intercept & slopr computed by "Ricker" or "Jolicoeur and Mosimann" procedure