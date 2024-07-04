%%% plot the boxplot of the anomalies in each bio indexes under MHW conditions             
close all
clear all

%import data
cd('...')
mashup=readtable('MHW-in situ data.xlsx','UseExcel',true,'Sheet','Data Table (1)');
rawmhwsate=readtable('MHW-satelliteChla.xlsx','UseExcel',true,'Sheet','Data Table (1)');

% extract anomalies & create name array 
absfano1low = str2double(mashup.Chlalow1um(isnan(str2double(mashup.Chlalow1um))==0));
absfano13 = str2double(mashup.Chla1_3um(isnan(str2double(mashup.Chla1_3um))==0));
absfano38 = str2double(mashup.Chla3_8um(isnan(str2double(mashup.Chla3_8um))==0));
absfano820 = str2double(mashup.Chla8_20um(isnan(str2double(mashup.Chla8_20um))==0));
absfano20up = str2double(mashup.ChlaLarger20um(isnan(str2double(mashup.ChlaLarger20um))==0));
hplc1 = str2double(mashup.DivinylChla(isnan(str2double(mashup.DivinylChla))==0)); 
hplc2 = str2double(mashup.Fucoxanthin(isnan(str2double(mashup.Fucoxanthin))==0));
hplc3 = str2double(mashup.Hexanoyloxyfucoxanthin(isnan(str2double(mashup.Hexanoyloxyfucoxanthin))==0));
ppano = str2double(mashup.IntPP(isnan(str2double(mashup.IntPP))==0));
chlano = mashup.IntChla(isnan(mashup.IntChla)==0);
picoano1 = str2double(mashup.HeteroBacteria(isnan(str2double(mashup.HeteroBacteria))==0));
picoano2 = str2double(mashup.Prochlorococcus(isnan(str2double(mashup.Prochlorococcus))==0));
picoano3 = str2double(mashup.Synechococcus(isnan(str2double(mashup.Synechococcus))==0));
picoano4 = str2double(mashup.Picoeukaryotes(isnan(str2double(mashup.Picoeukaryotes))==0));
sateano1 = rawmhwsate.Chla(isnan(rawmhwsate.Chla)==0);
nitra1=mashup.Nitracline(isnan(mashup.Nitracline)==0);
zc17.Anomaly=str2double(mashup.ZooDisplace(isnan(str2double(mashup.ZooDisplace))==0));
zc3.Anomaly=str2double(mashup.calanoid(isnan(str2double(mashup.calanoid))==0)); 
zc5.Anomaly=str2double(mashup.eucalanids(isnan(str2double(mashup.eucalanids))==0));
zc6.Anomaly=str2double(mashup.harpacticoida(isnan(str2double(mashup.harpacticoida))==0));
zc8.Anomaly=str2double(mashup.poecilostomatoids(isnan(str2double(mashup.poecilostomatoids))==0)); 
zc14.Anomaly=str2double(mashup.oithona(isnan(str2double(mashup.oithona))==0)); 
zc12.Anomaly=str2double(mashup.nauplii(isnan(str2double(mashup.nauplii))==0));
zc11.Anomaly=str2double(mashup.euphausiids(isnan(str2double(mashup.euphausiids))==0));
zc15.Anomaly=str2double(mashup.pyrosomes(isnan(str2double(mashup.pyrosomes))==0));
zc16.Anomaly=str2double(mashup.salps(isnan(str2double(mashup.salps))==0));
zc10.Anomaly=str2double(mashup.doliolids(isnan(str2double(mashup.doliolids))==0));
zc18.Ano_yjSardine=str2double(mashup.Sardine_egg(isnan(str2double(mashup.Sardine_egg))==0));
zc18.Ano_yjAnchovy=str2double(mashup.Anchovy_egg(isnan(str2double(mashup.Anchovy_egg))==0));
zc19.yj_sardine=str2double(mashup.Sardine_larvae(isnan(str2double(mashup.Sardine_larvae))==0));
zc19.yj_anchovy=str2double(mashup.Anchovy_larvae(isnan(str2double(mashup.Anchovy_larvae))==0));

% name array (spaces for consistent dimensions of arrays)
bioname=[repmat('Nitracline            ',length(nitra1),1);repmat('SurfaceChla           ',length(sateano1),1);repmat('VerIntChla            ',length(chlano),1);repmat('VerIntPP              ',length(ppano),1);...
         repmat('Chla<1um              ',length(absfano1low),1);repmat('Chla1-3um             ',length(absfano13),1);...
         repmat('Chla3-8um             ',length(absfano38),1);repmat(  'Chla8-20um            ',length(absfano820),1);...    
         repmat('Chla>20um             ',length(absfano20up),1);...
         repmat('Divinyl Chla          ',length(hplc1),1);repmat(   'Fucoxanthin           ',length(hplc2),1);repmat( 'Hexanoyloxyfucox      ',length(hplc3),1);...
         repmat('Prochlorococcus       ',length(picoano2),1);repmat('Synechococcus         ',length(picoano3),1);...
         repmat('HeteroBacteria        ',length(picoano1),1);repmat('Picoeukaryotes        ',length(picoano4),1)];
  %repmat('Stallite_npp   ',length(sateano2),1)];

%select certain zooplankton taxa (aligned with Rho barplot)
finalname=[repmat('ZooplanktonVolume',length(zc17.Anomaly),1);repmat('Calanoids        ',length(zc10.Anomaly),1);repmat('Eucalanids       ',length(zc10.Anomaly),1);repmat('Harpacticoida    ',length(zc10.Anomaly),1);...
  repmat('Poecilostomatoids',length(zc10.Anomaly),1);repmat('Oithona_like     ',length(zc10.Anomaly),1);repmat('Nauplii          ',length(zc10.Anomaly),1);...
  repmat('Euphausiids      ',length(zc11.Anomaly),1) ;repmat('Pyrosomes        ',length(zc16.Anomaly),1);...
  repmat('Salps            ',length(zc15.Anomaly),1); repmat('Doliolids        ',length(zc10.Anomaly),1);...
   repmat('Sardine Egg      ',length(zc18.Ano_yjSardine),1);repmat('Anchovy Egg      ',length(zc18.Ano_yjAnchovy),1);...
  repmat('Sardine Larvae   ',length(zc19.yj_sardine),1);repmat('Anchovy Larvae   ',length(zc19.yj_anchovy),1);];
      
% put all data into one table (short_lived plankton)
boxall = [nitra1;sateano1; chlano; ppano;...
    absfano1low ; absfano13; absfano38; absfano820; absfano20up;...
%     sfano1low ; sfano13; sfano38; sfano820; sfano20up;...
     hplc1 ; hplc2 ; hplc3...
    ; picoano2; picoano3;picoano1; picoano4 ]; %; sateano2];

%zooplankton
finalall = [zc17.Anomaly; zc3.Anomaly ;zc5.Anomaly ;zc6.Anomaly ;zc8.Anomaly ;zc14.Anomaly ;zc12.Anomaly ;...
    zc11.Anomaly ;zc15.Anomaly ;zc16.Anomaly ;zc10.Anomaly ;...
    zc18.Ano_yjSardine; zc18.Ano_yjAnchovy; zc19.yj_sardine; zc19.yj_anchovy];


% t test analysis (check if the distribtion of each category show significant reponse during MHW)
varlist={'nitra1';'sateano1'; 'chlano'; 'ppano';'absfano1low';'absfano13';'absfano38';'absfano820';'absfano20up';...
        'hplc1'; 'hplc2'; 'hplc3'; 'picoano2'; 'picoano3';'picoano1'; 'picoano4';'zc17.Anomaly'; 'zc3.Anomaly';...
        'zc5.Anomaly';'zc6.Anomaly';'zc8.Anomaly';'zc14.Anomaly';'zc12.Anomaly';...
        'zc11.Anomaly';'zc15.Anomaly';'zc16.Anomaly';'zc10.Anomaly';...
        'zc18.Ano_yjSardine';'zc18.Ano_yjAnchovy';'zc19.yj_sardine'; 'zc19.yj_anchovy'};
varname={'Nitracline';'SurfaceChla';'VerIntChla';'VerIntPP';...
         'Chla<1um';'Chla1-3um';'Chla3-8um';'Chla8-20um';'Chla>20um';...
         'Divinyl Chla';'Fucoxanthin';'Hexanoyloxyfucox';'Prochlorococcus';'Synechococcus';'HeteroBacteria';'Picoeukaryotes';...
         'ZooplanktonVolume';'Calanoids';'Eucalanids';'Harpacticoida';...
        'Poecilostomatoids';'Oithona_like';'Nauplii';'Euphausiids';'Pyrosomes';'Salps';'Doliolids';...
        'Sardine Egg';'Anchovy Egg';'Sardine Larvae';'Anchovy Larvae'};
tresult=array2table(nan(31,5));
tresult.Properties.VariableNames={'Index','mean','std','significane','pval'};
tresult.Index=string(varname);

% main t-test
for i=1:length(varlist)
eval(['[h,p,ci,stats] = ttest(',char(varlist(i)),')']);
eval(['aver=mean(',char(varlist(i)),',"omitnan")']);
tresult.mean(i)= aver;
tresult.std(i)= stats.sd;
tresult.significane(i) = h;
tresult.pval(i) = p;
end
% save table
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results\')
writetable(tresult,'v2_ttest_boxplot_south.csv')

% plot boxplot
p1=figure('pos',[10 10 20000 10000])
% subplot(28,4,[1:56])
boxplot(boxall,bioname,'PlotStyle','traditional',"BoxStyle","outline",...
    "OutlierSize",5,"Symbol","o")
% xlabel('Taxonomy groups');
ylabel('Anomaly (trans-abundance)','fontsize', 10); % modify figure information
set(gca,'fontsize', 16,'fontweight','bold');
yline(0,'--','linew',2)
set(findobj(gca,'type','line'),'linew',1.5);
title('(a) Short-lived microbes + Nitracline')
ylim([-3 3])
yticks([-3 -1.5 0 1.5 3])

% zooplankton
p2=figure('pos',[10 10 20000 10000])
% subplot(28,4,[57:112])
boxplot(finalall,finalname,'PlotStyle','traditional',"BoxStyle","outline",...
    "OutlierSize",5,"Symbol","o")
ylabel('Anomaly (trans-abundance)','fontsize', 10); % modify figure information
set(gca,'fontsize', 16,'fontweight','bold');
yline(0,'--','linew',2)
set(findobj(gca,'type','line'),'linew',1.5);
title('(b) Zooplankton & Fish')
ylim([-3.5 3.5])
yticks([-3 -1.5 0 1.5 3])
