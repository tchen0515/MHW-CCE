%%% calculate the coef and glm or Geometric Mean Regression results for bio-MHW
%%% bio-MHW (file:ZooScan & Fish Eggs)
close all
clear all

% import data
cd('...')
mashup=readtable('MHW-in situ data.xlsx','UseExcel',true,'Sheet','Data Table (1)');
v={'Latitude','Longitude','Line','Station','Year','Month','Day','anoSST','rlduration'}
zc1=mashup(:,[v 'calanoid']);
zc2=mashup(:,[v 'eucalanids']);
zc3=mashup(:,[v 'harpacticoida']);
zc4=mashup(:,[v 'poecilostomatoids']);
zc5=mashup(:,[v 'euphausiids']);
zc6=mashup(:,[v 'nauplii']);
zc7=mashup(:,[v 'oithona']);
zc8=mashup(:,[v 'pyrosomes']);
zc9=mashup(:,[v 'salps']);
zc10=mashup(:,[v 'doliolids']);
zc11=mashup(:,[v 'ZooDisplace']);
zc12=mashup(:,[v 'Sardine_egg' 'Anchovy_egg']);
zc13=mashup(:,[v 'Sardine_larvae' 'Anchovy_larvae']);
%covert the corresponding variables into numeric values
zc1.Anomaly=str2double(zc1.calanoid);
zc2.Anomaly=str2double(zc2.eucalanids);
zc3.Anomaly=str2double(zc3.harpacticoida);
zc4.Anomaly=str2double(zc4.poecilostomatoids);
zc5.Anomaly=str2double(zc5.euphausiids);
zc6.Anomaly=str2double(zc6.nauplii);
zc7.Anomaly=str2double(zc7.oithona);
zc8.Anomaly=str2double(zc8.pyrosomes);
zc9.Anomaly=str2double(zc9.salps);
zc10.Anomaly=str2double(zc10.doliolids);
zc11.Anomaly=str2double(zc11.ZooDisplace);
zc12.Sardine_egg=str2double(zc12.Sardine_egg);
zc12.Anchovy_egg=str2double(zc12.Anchovy_egg);
zc13.Sardine_larvae=str2double(zc13.Sardine_larvae);
zc13.Anchovy_larvae=str2double(zc13.Anchovy_larvae);

% extract variables
for k=1:11
    zc=sprintf('zc%d',k);
    eval([sprintf('zoo%d',k),'=',zc,'.Anomaly(isnan(',zc,'.Anomaly)==0)']); %normal
end
%fish eggs
zoo12=zc12.Sardine_egg(isnan(zc12.Sardine_egg)==0);  %sardine
zoo13=zc12.Anchovy_egg(isnan(zc12.Anchovy_egg)==0);  %anchovy 
% fish larvae
zoo14=zc13.Sardine_larvae(isnan(zc13.Sardine_larvae)==0);  %sardine
zoo15=zc13.Anchovy_larvae(isnan(zc13.Anchovy_larvae)==0);

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
        intensity = zc12.anoSST(isnan(zc12.Sardine_egg)==0); % gev
        duration = zc12.rlduration(isnan(zc12.Sardine_egg)==0); % nbin
   elseif i==13    % anchovy
        intensity = zc12.anoSST(isnan(zc12.Anchovy_egg)==0); % gev
        duration = zc12.rlduration(isnan(zc12.Anchovy_egg)==0); % nbin
   elseif i==14    % sardine
        intensity = zc13.anoSST(isnan(zc13.Sardine_larvae)==0); % gev
        duration = zc13.rlduration(isnan(zc13.Sardine_larvae)==0); % nbin
   elseif i==15    % anchovy
        intensity = zc13.anoSST(isnan(zc13.Anchovy_larvae)==0); % gev
        duration = zc13.rlduration(isnan(zc13.Anchovy_larvae)==0); % nbin
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
"sardine-larvae";
"anchovy-larvae"]);
finalpara=[variable para];
finalpara.Properties.VariableNames=["Index","Size","int-Rho","int-pval","B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R",...
    "CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM","dur-Rho","dur-pval","B2_int","B2_slope","CI2_int_low_R","CI2_int_up_R","CI2_slo_low_R",...
    "CI2_slo_up_R","CI2_int_low_JM","CI2_int_up_JM","CI2_slo_low_JM","CI2_slo_up_JM"]

% export the table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(finalpara,"Oriresult_Zooplankton&Fish_south.csv") 
