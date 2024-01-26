%%% plot the boxplot of the anomalies in each bio indexes under MHW
%%% conditions              last update:2023/12/17
close all
clear all

% import data
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
sf = readtable('Final_MHW_SizeFraction_v2.csv',VariableNamingRule='preserve');
pp = readtable('Final_MHW_PP_trape.csv',VariableNamingRule='preserve');
chla = readtable('Final_MHW_Chla_trape.csv',VariableNamingRule='preserve');
pico = readtable('Final_MHW_PicoBacteria_aver10m.csv',VariableNamingRule='preserve');
hplc = readtable('Final_MHW_HPLC.csv',VariableNamingRule='preserve');
satellite = readtable('MHWOccurrence_negmostChla.csv',VariableNamingRule='preserve');

%import data (selected metazoan group)
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio')
% zc1 = readtable('Final_MHW_YJ_ZooScan_all_biomass.csv',VariableNamingRule='preserve');
% zc2 = readtable('Final_MHW_YJ_ZooScan_all_copepods.csv',VariableNamingRule='preserve');
zc3 = readtable('Final_MHW_YJ_ZooScan_Calanoid_copepod.csv',VariableNamingRule='preserve');
% zc4 = readtable('Final_MHW_YJ_ZooScan_copepoda_calanoida.csv',VariableNamingRule='preserve');
zc5 = readtable('Final_MHW_YJ_ZooScan_copepoda_eucalanids.csv',VariableNamingRule='preserve');
zc6 = readtable('Final_MHW_YJ_ZooScan_copepoda_harpacticoida.csv',VariableNamingRule='preserve');
% zc7 = readtable('Final_MHW_YJ_ZooScan_copepoda_other.csv',VariableNamingRule='preserve');
zc8 = readtable('Final_MHW_YJ_ZooScan_copepoda_poecilostomatoids.csv',VariableNamingRule='preserve');
% zc9 = readtable('Final_MHW_YJ_ZooScan_crustacea_others.csv',VariableNamingRule='preserve');
zc10 = readtable('Final_MHW_YJ_ZooScan_doliolids.csv',VariableNamingRule='preserve');
zc11 = readtable('Final_MHW_YJ_ZooScan_euphausiids.csv',VariableNamingRule='preserve');
zc12 = readtable('Final_MHW_YJ_ZooScan_nauplii.csv',VariableNamingRule='preserve');
% zc13 = readtable('Final_MHW_YJ_ZooScan_Non-Calanoid_copepod.csv',VariableNamingRule='preserve');
zc14 = readtable('Final_MHW_YJ_ZooScan_oithona_like.csv',VariableNamingRule='preserve');
zc15 = readtable('Final_MHW_YJ_ZooScan_pyrosomes.csv',VariableNamingRule='preserve');
zc16 = readtable('Final_MHW_YJ_ZooScan_salps.csv',VariableNamingRule='preserve');
zc17 = readtable('Final_MHW_ZooDisplace.csv',VariableNamingRule='preserve');
zc18 = readtable('Final_MHW_FishEgg_integrated_025grid_1215.csv',VariableNamingRule='preserve');
zc19 = readtable('Final_MHW_Fishlarvae1215.csv',VariableNamingRule='preserve');

% extract anomalies & create name array 
absfano1low = sf.absChlower1um;
absfano13 = sf.("absChla1-3um");
absfano38 = sf.("absChla3-8um");
absfano820 = sf.("absChla8-20um");
absfano20up = sf.("absChlalarge20um");
% sfano1low = sf.Chlalower1um;
% sfano13 = sf.("Chla1-3um");
% sfano38 = sf.("Chla3-8um");
% sfano820 = sf.("Chla8-20um");
% sfano20up = sf.("Chlalarge20um");
hplc1 = hplc.dvChla; 
hplc2 = hplc.fucox;
hplc3 = hplc.hexfucox;
ppano = pp.PP;
chlano = chla.Chla;
picoano1 = pico.HeteroBacteria;
picoano2 = pico.Prochlorococcus;
picoano3 = pico.Synechococcus;
picoano4 = pico.Picoeukaryotes;
sateano1 = satellite.Chla;
%sateano2 = sate.nppano;

% name array (spaces for consistent dimensions of arrays)
bioname=[repmat('SatelliteChla         ',length(sateano1),1);repmat('VerIntChla            ',length(chlano),1);repmat('VerIntPP              ',length(ppano),1);...
         repmat('Chla<1um              ',length(absfano1low),1);repmat('Chla1-3um             ',length(absfano13),1);...
         repmat('Chla3-8um             ',length(absfano38),1);repmat(  'Chla8-20um            ',length(absfano820),1);...    
         repmat('Chla>20um             ',length(absfano20up),1);...
%          repmat('Chla<1um %            ',length(sfano1low),1);...
%          repmat('Chla1-3um %           ',length(sfano13),1);repmat(  'Chla3-8um %           ',length(sfano38),1);...
%          repmat('Chla8-20um %          ',length(sfano820),1);repmat(  'Chla>20um %           ',length(sfano20up),1);...
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
boxall = [sateano1; chlano; ppano;...
    absfano1low ; absfano13; absfano38; absfano820; absfano20up;...
%     sfano1low ; sfano13; sfano38; sfano820; sfano20up;...
     hplc1 ; hplc2 ; hplc3...
    ; picoano2; picoano3;picoano1; picoano4 ]; %; sateano2];

%zooplankton
finalall = [zc17.Anomaly; zc3.Anomaly ;zc5.Anomaly ;zc6.Anomaly ;zc8.Anomaly ;zc14.Anomaly ;zc12.Anomaly ;...
    zc11.Anomaly ;zc15.Anomaly ;zc16.Anomaly ;zc10.Anomaly ;...
    zc18.Ano_yjSardine; zc18.Ano_yjAnchovy; zc19.yj_sardine; zc19.yj_anchovy];


% % ANOVA analysis
% box=array2table(boxall); 
% box.Name=bioname;
% anova(box,"boxall",FactorNames=["Name"])
% % need post-hoc test
mean(zc18.Ano_yjSardine,'omitnan')
mean(zc18.Ano_yjAnchovy,'omitnan')
mean(zc19.yj_sardine,'omitnan')
mean(zc19.yj_anchovy,'omitnan')
std(zc18.Ano_yjSardine,'omitnan')
std(zc18.Ano_yjAnchovy,'omitnan')
std(zc19.yj_sardine,'omitnan')
std(zc19.yj_anchovy,'omitnan')
bio=sateano1;
mean(bio ,'omitnan') 
std(bio,'omitnan')

% absfano13; absfano38; absfano820; absfano20up;
length(find(zc18.Ano_yjAnchovy>0))/length(find(isnan(zc18.Ano_yjAnchovy)==0))

zc18.Ano_yjAnchovy(find(zc18.Ano_yjAnchovy>0))


% boxplot
p1=figure('pos',[10 10 20000 10000])
% subplot(28,4,[1:56])
boxplot(boxall,bioname,'PlotStyle','traditional',"BoxStyle","outline",...
    "OutlierSize",5,"Symbol","o")
% xlabel('Taxonomy groups');
ylabel('Anomaly (log_1_0 abundance)','fontsize', 8); % modify figure information
set(gca,'fontsize', 12,'fontweight','bold');
yline(0,'--','linew',2)
set(findobj(gca,'type','line'),'linew',1.5);
title('(a) Short-lived microbes')
ylim([-3 3])
yticks([-3 -1.5 0 1.5 3])

% zooplankton
p2=figure('pos',[10 10 20000 10000])
% subplot(28,4,[57:112])
boxplot(finalall,finalname,'PlotStyle','traditional',"BoxStyle","outline",...
    "OutlierSize",5,"Symbol","o")
ylabel('Anomaly (trans-abundance)','fontsize', 8); % modify figure information
set(gca,'fontsize', 12,'fontweight','bold');
yline(0,'--','linew',2)
set(findobj(gca,'type','line'),'linew',1.5);
title('(b) Zooplankton & Fish')
ylim([-3.5 3.5])
yticks([-3 -1.5 0 1.5 3])

%save figure
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\mhwbio_figure\boxplot')
savefig(p1,'boxplot_combined_231215.fig')