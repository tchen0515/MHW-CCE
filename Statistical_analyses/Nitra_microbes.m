%%% Write the tables of MHWOccurrence for Nitrocline & other microbial anomalies 
close all
clear all

cd('...')
mashup=readtable('MHW-in situ data.xlsx','UseExcel',true,'Sheet','Data Table (1)');
cd ('...')
rawsate= readtable("Nitra_satelliteChla.csv",VariableNamingRule='preserve');

%exclude the sampling conducted in the northern region
sate=rawsate(rawsate.Line>=76.7,:);
pp=rawpp(rawpp.Line>=76.7,:);
chla=rawchla(rawchla.Line>=76.7,:);
nitra=rawnitra(rawnitra.Line>=76.7,:);


% % extract anomalies & create name array 
% absfano1low = sf.absChlower1um;
% absfano13 = sf.("absChla1-3um");
% absfano38 = sf.("absChla3-8um");
% absfano820 = sf.("absChla8-20um");
% absfano20up = sf.("absChlalarge20um");
% hplc1 = hplc.dvChla; 
% hplc2 = hplc.fucox;
% hplc3 = hplc.hexfucox;
% ppano = pp.PP;
% chlano = chla.Chla;
% picoano1 = pico.HeteroBacteria;
% picoano2 = pico.Prochlorococcus;
% picoano3 = pico.Synechococcus;
% picoano4 = pico.Picoeukaryotes;

filelist={'chla','pp','sf','pico','hplc','sate'};
varlist={'sateano1'; 'chlano'; 'ppano';'absfano1low';'absfano13';'absfano38';'absfano820';'absfano20up';...
        'hplc1'; 'hplc2'; 'hplc3'; 'picoano2'; 'picoano3';'picoano1'; 'picoano4'};

for i=1:length(filelist)
% algin the co-occurrence of nitracline and microbial anomalies
if string(filelist(i))=='sate'
    microvar=sate.Chla(~isnan(sate.Chla));
    nitraAno=sate.ano_nitra(~isnan(sate.Chla));
[rho1,pval1]=corr(microvar,nitraAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(microvar,nitraAno) 

%write all parameters into the table (sample size, Rho, pval, type II parameters)
para0=[height(nitraAno),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:)];
para0=array2table(para0);
variable=array2table(["SatelliteChla"]);
finalpara0=[variable para0];
finalpara0.Properties.VariableNames=["MicroIndex","Size","Rho","pval",...
    "B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R","CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM"];


else
% sampling station + date
eval(['micro=',char(filelist(i))]);
microloc=[micro.Line micro.Station micro.Year micro.Month micro.Day];
nitraloc=[rawnitra.Line rawnitra.Station rawnitra.Year rawnitra.Month rawnitra.Day];
targetrow=find(ismember(microloc,nitraloc,"rows"));  
candidate=micro(targetrow,:); % the microbial anomalies co-occurred with nutrient sampling during MHW

%extract nitracline variables
for k=1:height(candidate)
    targetrow2=find(ismember(nitraloc,microloc,"rows")); % which nutrient co-occurred with microbial anomalies
    candinitra=rawnitra(targetrow2,:);
    candidate.nitra=candinitra.ano_nitra; % combine to selected microbial anomalies
end

%% extract different variables in each dataset to run correlation analysis
if string(filelist(i))=='chla' % chla

va = ["Chla"];
eval([sprintf('microvar=candidate.%s',va)]);
nitraAno=candidate.nitra;

[rho1,pval1]=corr(microvar,nitraAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(microvar,nitraAno) 

%write all parameters into the table (sample size, Rho, pval, type II parameters)
para1=[height(nitraAno),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:)];
para1=array2table(para1);
variable=array2table(["VerIntChla"]);
finalpara1=[variable para1];
finalpara1.Properties.VariableNames=["MicroIndex","Size","Rho","pval",...
    "B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R","CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM"];


elseif string(filelist(i))=='pp'% pp

va = ["PP"];
eval([sprintf('microvar=candidate.%s',va)]);
nitraAno=candidate.nitra;

[rho1,pval1]=corr(microvar,nitraAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(microvar,nitraAno) 

%write all parameters into the table (sample size, Rho, pval, type II parameters)
para2=[height(nitraAno),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:)];
para2=array2table(para2);
variable=array2table(["VerIntPP"]);
finalpara2=[variable para2];
finalpara2.Properties.VariableNames=["MicroIndex","Size","Rho","pval",...
    "B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R","CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM"];

elseif string(filelist(i))=='sf' % sf

va = ["absChlower1um";"('absChla1-3um')";"('absChla3-8um')";"('absChla8-20um')";"('absChlalarge20um')"];
para3=nan(length(va),13); % final table for statistical result
for j=1:length(va)
eval([sprintf('microvar=candidate.%s',va(j))]);
nitraAno=candidate.nitra;

[rho1,pval1]=corr(microvar,nitraAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(microvar,nitraAno) 

%write all parameters into the table (sample size, Rho, pval, type II parameters)
para3(j,:)=[height(nitraAno),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:)];
end
para3=array2table(para3);
variable=array2table(["Chla<1um";"Chla1-3um";"Chla3-8um";"Chla8-20um";"Chla>20um"]);
finalpara3=[variable para3];
finalpara3.Properties.VariableNames=["MicroIndex","Size","Rho","pval",...
    "B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R","CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM"];

elseif string(filelist(i))=='pico' % pico

va = ["Prochlorococcus";"Synechococcus";"HeteroBacteria";"Picoeukaryotes"];
para4 = nan(length(va),13); % final table for statistical result
for j=1:length(va)
eval([sprintf('microvar=candidate.%s',va(j))]);
candidate2=candidate; % prevent the NA values
candidate2(isnan(microvar),:)=[];
eval([sprintf('microvar=candidate2.%s',va(j))]);
nitraAno=candidate2.nitra;

[rho1,pval1]=corr(microvar,nitraAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(microvar,nitraAno) 

%write all parameters into the table (sample size, Rho, pval, type II parameters)
para4(j,:)=[height(nitraAno),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:)];
end
para4=array2table(para4);
variable=array2table(["Prochlorococcus";"Synechococcus";"HeteroBacteria";"Picoeukaryotes"]);
finalpara4=[variable para4];
finalpara4.Properties.VariableNames=["MicroIndex","Size","Rho","pval",...
    "B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R","CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM"];


elseif string(filelist(i))=='hplc' % hplc

% spearman's rank coefficient
va = ["dvChla";"fucox";"hexfucox"];
para5 = nan(length(va),13); % final table for statistical result
for j=1:length(va)
eval([sprintf('microvar=candidate.%s',va(j))]);
candidate2=candidate; % prevent the NA values
candidate2(isnan(microvar),:)=[];
eval([sprintf('microvar=candidate2.%s',va(j))]);
nitraAno=candidate2.nitra;

[rho1,pval1]=corr(microvar,nitraAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
[b1,bintr1,bintjm1] = gmregress(microvar,nitraAno) 

%write all parameters into the table (sample size, Rho, pval, type II parameters)
para5(j,:)=[height(nitraAno),rho1,pval1,b1(1),b1(2),bintr1(1,:),bintr1(2,:),bintjm1(1,:),bintjm1(2,:)];
end
para5=array2table(para5);
variable=array2table(["Divinyl Chla";"Fucoxanthin";"Hexanoyloxyfucox"]);
finalpara5=[variable para5];
finalpara5.Properties.VariableNames=["MicroIndex","Size","Rho","pval",...
    "B_int","B_slope","CI_int_low_R","CI_int_up_R","CI_slo_low_R","CI_slo_up_R","CI_int_low_JM","CI_int_up_JM","CI_slo_low_JM","CI_slo_up_JM"];
end
end
end

%put all variable result together
bigfinal=[finalpara0;finalpara1;finalpara2;finalpara3;finalpara4;finalpara5];

%export table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
writetable(bigfinal,'OriNitraMicro_south.csv')

