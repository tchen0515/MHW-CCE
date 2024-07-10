%%% investigate whether there is latitudual difference in CalCOFI data
clear all
close all

%% import that biological data that conducted sampling in both northen and
% southern region (use line 76.7 as the boundary)
cd('...\CalCOFI\Output\output_mhwbio\OriBio-SDMHW')
intchla=readtable("OriFinal_MHW_Chla_trape.csv","VariableNamingRule","preserve");
zdv=readtable("OriFinal_MHW_ZooDisplace.csv","VariableNamingRule","preserve");
nitra = readtable('OriFinal_MHW_Nitracline.csv',VariableNamingRule='preserve');  % data generated by (std)anomaly_Nitracline.m

% data with only global coordinate (need convertion)
fegg=readtable("OriFinal_MHW_FishEgg_integrated_025grid_1215.csv","VariableNamingRule","preserve");
% addpath '...\CalCOFI\Output\output_mhwbio\')
satechla=readtable("OriMHWOccurrence_negmostChla.csv","VariableNamingRule","preserve");

%% insert line station coverted information
addpath '...\CalCOFI\code_CalCOFI\CalCOFILineStationMatLab'
addpath '...\matlab&linux'
[sateli, satest]=lat2cc(satechla.lat,satechla.long)
[fli, fst]=lat2cc(fegg.Latitude,fegg.Longitude)
satechla.line= sateli;
satechla.station= satest;
fegg.line= fli;
fegg.station= fst;

%% seperate the regions
% northern
nintchla=intchla(intchla.Line<76.7,:);
nzdv=zdv(zdv.Line<76.7,:);
nfegg=fegg(fegg.line<76.7,:);
nsatechla=satechla(satechla.line<76.7,:);
nnitra=nitra(nitra.Line<76.7,:);

% southern
sintchla=intchla(intchla.Line>=76.7,:);
szdv=zdv(zdv.Line>=76.7,:);
sfegg=fegg(fegg.line>=76.7,:);
ssatechla=satechla(satechla.line>=76.7,:);
snitra=nitra(nitra.Line>=76.7,:);

% Spearman correlation analysis
filelist={'nsatechla','nintchla','nzdv','nnitra','nfegg','ssatechla','sintchla','szdv','snitra','sfegg'};
allrho=nan(length(filelist),26);  % all correlation analysis results
fpara=nan(4,25); % correlation analysis results for fish egg
for i=1:length(filelist)
% algin the co-occurrence of nitracline and microbial anomalies
if string(filelist(i))=='nfegg'||string(filelist(i))=='sfegg'
    eval(['bio=',char(filelist(i))]);
    va = ["Ano_yjSardine";"Ano_yjAnchovy"];
    
for l=1:2
eval([sprintf('var=bio.%s',va(l))]);
    ano=var(~isnan(var));
    intensity=bio.anoSST(~isnan(var),:);
    duration=bio.rlduration(~isnan(var),:);

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
if string(filelist(i))=='nfegg'
fpara(l,:)=[height(ano),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:),rho2,pval2,b2(1),b2(2),...
    bintr2(1,:),bintr2(2,:),bintjm2(1,:),bintjm2(2,:)];
elseif string(filelist(i))=='sfegg'
fpara(l+2,:)=[height(ano),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:),rho2,pval2,b2(1),b2(2),...
    bintr2(1,:),bintr2(2,:),bintjm2(1,:),bintjm2(2,:)];   
end

end

else

if string(filelist(i))=='nsatechla'||string(filelist(i))=='ssatechla'
    eval(['bio=',char(filelist(i))]);
    bio2=bio(~isnan(bio.Chla),:);
    ano=bio2.Chla;
    intensity=bio2.int_max;
    duration=bio2.mhw_dur;

elseif string(filelist(i))=='nintchla'||string(filelist(i))=='sintchla'
    eval(['bio=',char(filelist(i))])
    bio2=bio(~isnan(bio.Chla),:);
    ano=bio2.Chla; 
    intensity=bio2.anoSST;
    duration=bio2.rlduration;
elseif string(filelist(i))=='nzdv'||string(filelist(i))=='szdv'
    eval(['bio=',char(filelist(i))])
    bio2=bio(~isnan(bio.Anomaly),:);
    ano=bio2.Anomaly;
    intensity=bio2.anoSST;
    duration=bio2.rlduration;
elseif string(filelist(i))=='nnitra'||string(filelist(i))=='snitra'   
    eval(['bio=',char(filelist(i))])
    bio2=bio(~isnan(bio.ano_nitra),:);
    ano=bio2.ano_nitra;
    intensity=bio2.anoSST;
    duration=bio2.rlduration;    
end
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

% assign the result into correspondent rows
allrho(i,1)=i;
allrho(i,2:end)=[height(ano),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:),rho2,pval2,b2(1),b2(2),...
    bintr2(1,:),bintr2(2,:),bintjm2(1,:),bintjm2(2,:)];
end

end
fpara=array2table(fpara);
variable=array2table(["N-SardineEgg";"N-AnchovyEgg";"S-SardineEgg";"S-AnchovyEgg"]);
finalpara=[variable fpara];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

allrho=array2table(allrho);
allrho.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

finalrho=[allrho(1:4,:);finalpara(1:2,:);allrho(6:9,:);finalpara(3:4,:)];
finalrho.Index=["N-SatelliteChla";"N-IntChla";"N-ZDV";"N-Nitra";"N-SardineEgg";"N-AnchovyEgg";...
    "S-SatelliteChla";"S-IntChla";"S-ZDV";"S-Nitra";"S-SardineEgg";"S-AnchovyEgg"];

% boxplot t-test
n1=nsatechla.Chla;
n2=nintchla.Chla;
n3=nzdv.Anomaly;
n4=nfegg.Ano_yjSardine;
n5=nfegg.Ano_yjAnchovy;
s1=ssatechla.Chla;
s2=sintchla.Chla;
s3=szdv.Anomaly;
s4=sfegg.Ano_yjSardine;
s5=sfegg.Ano_yjAnchovy;
varlist={'n1','n2','n3','n4','n5','s1','s2','s3','s4','s5'};

tresult=array2table(nan(length(varlist),5));
tresult.Properties.VariableNames={'Index','mean','std','significane','pval'};
tresult.Index=["N-SatelliteChla";"N-IntChla";"N-ZDV";"N-SardineEgg";"N-AnchovyEgg";...
    "S-SatelliteChla";"S-IntChla";"S-ZDV";"S-SardineEgg";"S-AnchovyEgg"];

for i=1:length(varlist)
eval(['[h,p,ci,stats] = ttest(',char(varlist(i)),')']);
eval(['aver=mean(',char(varlist(i)),',"omitnan")']);
tresult.mean(i)= aver;
tresult.std(i)= stats.sd;
tresult.significane(i) = h;
tresult.pval(i) = p;
end

% export table
cd('...\CalCOFI\Output\output_mhwbio\statistical_results\')
writetable(finalrho,'OriCalCOFI_regionalsub.csv')  % correlation
writetable(tresult,'Orittest_regionalsub.csv')% boxplot t-test

