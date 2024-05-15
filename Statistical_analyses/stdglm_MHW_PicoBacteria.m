%%% calculate the coef and glm or Geometric Mean Regression results for
%%% bio-MHW (file:PicoBacteria)
close all
clear all
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\std_final\')
puremhw = readtable('OriFinal_MHW_PicoBacteria_aver10m.csv',VariableNamingRule='preserve'); 

% extract variables (1) eliminate NA values
bacteria1=puremhw.HeteroBacteria(isnan(puremhw.HeteroBacteria)==0);  %normal
bacteria2=puremhw.Prochlorococcus(isnan(puremhw.Prochlorococcus)==0);  %normal
bacteria3=puremhw.Synechococcus(isnan(puremhw.Synechococcus)==0);   %normal
bacteria4=puremhw.Picoeukaryotes(isnan(puremhw.Picoeukaryotes)==0);   %normal

% Check the data distribution (package:fitmethis)
% addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
% X = fitmethis(bacteria1); % output will indicate the rank of distribution type and show the hist polt


% Main statistical analysis part (maunally change the variable name)
for i=1:4
if i==2    %make sure the y indexes are corresponding
    intensity = puremhw.anoSST(isnan(puremhw.Prochlorococcus)==0); % gev
    duration = puremhw.rlduration(isnan(puremhw.Prochlorococcus)==0); % nbin
else
     intensity = puremhw.anoSST; % gev
     duration = puremhw.rlduration; % nbin
end
eval(['ano=',sprintf('bacteria%d',i)]);

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
variable=array2table(["HeteroBacteria";"Prochlorococcus";"Synechococcus";"Picoeukaryotes"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

% export the table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(finalpara,"Oriresult_PicoBacteria.csv")


