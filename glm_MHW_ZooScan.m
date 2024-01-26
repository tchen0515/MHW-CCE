%%% calculate the coef and glm or Geometric Mean Regression results for bio-MHW
%%% bio-MHW (file:ZooScan & Fish Eggs)
close all
clear all
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
%import data
zc1 = readtable('Final_MHW_YJ_ZooScan_Calanoid_copepod.csv',VariableNamingRule='preserve');
zc2 = readtable('Final_MHW_YJ_ZooScan_copepoda_eucalanids.csv',VariableNamingRule='preserve');
zc3 = readtable('Final_MHW_YJ_ZooScan_copepoda_harpacticoida.csv',VariableNamingRule='preserve');
zc4 = readtable('Final_MHW_YJ_ZooScan_copepoda_poecilostomatoids.csv',VariableNamingRule='preserve');
zc5 = readtable('Final_MHW_YJ_ZooScan_euphausiids.csv',VariableNamingRule='preserve');
zc6 = readtable('Final_MHW_YJ_ZooScan_nauplii.csv',VariableNamingRule='preserve');
zc7 = readtable('Final_MHW_YJ_ZooScan_oithona_like.csv',VariableNamingRule='preserve');
zc8 = readtable('Final_MHW_YJ_ZooScan_pyrosomes.csv',VariableNamingRule='preserve');
zc9 = readtable('Final_MHW_YJ_ZooScan_salps.csv',VariableNamingRule='preserve');
zc10 = readtable('Final_MHW_YJ_ZooScan_doliolids.csv',VariableNamingRule='preserve');
zc11 = readtable('Final_MHW_ZooDisplace.csv',VariableNamingRule='preserve');
zc12 = readtable('Final_MHW_FishEgg_integrated_025grid_1215.csv',VariableNamingRule='preserve');
zc13 = readtable('Final_MHW_FishLarvae1215.csv',VariableNamingRule='preserve');

% extract variables
for k=1:11
    zc=sprintf('zc%d',k);
    eval([sprintf('zoo%d',k),'=',zc,'.Anomaly(isnan(',zc,'.Anomaly)==0)']); %normal
end
%fish eggs
zoo12=zc12.Ano_yjSardine(isnan(zc12.Ano_yjSardine)==0);  %sardine
zoo13=zc12.Ano_yjAnchovy(isnan(zc12.Ano_yjAnchovy)==0);  %anchovy 
% fish larvae
zoo14=zc13.yj_sardine(isnan(zc13.yj_sardine)==0);  %sardine
zoo15=zc13.yj_anchovy(isnan(zc13.yj_anchovy)==0);

% Check the data distribution (package:fitmethis)
 addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
%  X = fitmethis(zoo14);
% X = fitmethis(duration); % output will indicate the rank of distribution type and show the hist polt

% Main statistical analysis part (maunally change the variable name)

for i=1:15
   if any(i==1:11)  %zooscan
        zc=sprintf('zc%d',i);
        intensity = eval([zc,'.anoSST(isnan(',zc,'.Anomaly)==0)']);
        duration = eval([zc,'.rlduration(isnan(',zc,'.Anomaly)==0)']);
   elseif i==12  % sardine
        intensity = zc12.anoSST(isnan(zc12.Ano_yjSardine)==0); % gev
        duration = zc12.rlduration(isnan(zc12.Ano_yjSardine)==0); % nbin
   elseif i==13    % anchovy
        intensity = zc12.anoSST(isnan(zc12.Ano_yjAnchovy)==0); % gev
        duration = zc12.rlduration(isnan(zc12.Ano_yjAnchovy)==0); % nbin
   elseif i==14    % sardine
        intensity = zc13.anoSST(isnan(zc13.yj_sardine)==0); % gev
        duration = zc13.rlduration(isnan(zc13.yj_sardine)==0); % nbin
   elseif i==15    % anchovy
        intensity = zc13.anoSST(isnan(zc13.yj_anchovy)==0); % gev
        duration = zc13.rlduration(isnan(zc13.yj_anchovy)==0); % nbin
   end
eval(['ano=',sprintf('zoo%d',i)]);

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
variable=array2table(["calanoid";
"copepoda-eucalanids";
"copepoda-harpacticoida";
"copepoda-poecilostomatoids";
"euphausiids";
"nauplii";
"oithona-like";
"pyrosomes";
"salps";
"doliolids";
"ZooDisplace";
"sardine-egg";
"anchovy-egg"; ...
"sardine";
"anchovy"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

% export the table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(finalpara,"result_Zooplankton&Fish_integrated1215.csv") 


% regression coefficients & a matrix BINT of the given confidence intervals for B
% b=[intercept slope]
% bintr & bintjm= confidence limits of intercept & slopr computed by "Ricker" or "Jolicoeur and Mosimann" procedure
