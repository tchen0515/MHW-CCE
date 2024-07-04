%%% calculate the coef and glm or Geometric Mean Regression results for
%%% variables:SizeFraction
close all
clear all
% cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\OriBio-SDMHW\')
% puremhw = readtable('OriFinal_MHW_SizeFraction_113_v2.csv',VariableNamingRule='preserve'); 
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\maunscript\MHW-bio\submission materials\Final data & code\')
mashup=readtable('MHW-in situ data.xlsx','UseExcel',true,'Sheet','Data Table (1)');
mashup.Chlalow1um=str2double(mashup.Chlalow1um);
mashup.("Chla1_3um")=str2double(mashup.("Chla1_3um"));
mashup.("Chla3_8um")=str2double(mashup.("Chla3_8um"));
mashup.("Chla8_20um")=str2double(mashup.("Chla8_20um"));
mashup.ChlaLarger20um=str2double(mashup.ChlaLarger20um);
puremhw=mashup;


% extract variables (1) eliminate NA values
 chla1= puremhw.Chlalow1um(isnan(puremhw.Chlalow1um)==0); %normal
 chla2= puremhw.("Chla1_3um")(isnan(puremhw.("Chla1_3um"))==0); %normal
 chla3= puremhw.("Chla3_8um")(isnan(puremhw.("Chla3_8um"))==0); %normal
 chla4= puremhw.("Chla8_20um")(isnan(puremhw.("Chla8_20um"))==0); %normal
 chla5= puremhw.ChlaLarger20um(isnan(puremhw.ChlaLarger20um)==0); %normal
 
% Check the data distribution (package:fitmethis)
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux'
% X = fitmethis(chla2);
% X = fitmethis(duration); % output will indicate the rank of distribution type and show the hist polt

% Main statistical analysis part (maunally change the variable name)
for i=1:5
if i==4    %make sure the y indexes are corresponding
    intensity = puremhw.anoSST(isnan(puremhw.("Chla8_20um"))==0); % gev
    duration = puremhw.rlduration(isnan(puremhw.("Chla8_20um"))==0); % nbin
else
     intensity = puremhw.anoSST(isnan(puremhw.Chlalow1um)==0); % gev
     duration = puremhw.rlduration(isnan(puremhw.Chlalow1um)==0); % nbin
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
variable=array2table(["Chlalow1um";"Chla1_3um";"Chla3_8um";"Chla8_20um";"ChlaLarger20um"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

% export the table
cd ('...')
writetable(finalpara,"Oriresult_SizeFraction.csv")


