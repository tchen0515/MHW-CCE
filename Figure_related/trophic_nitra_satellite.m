%%% write a table for cascading trophic interaction analysis (satellite-fucox)
clear all
close all
% import data (Final_MHW)
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\')
satellite = readtable("Nitra_satelliteChla.csv","VariableNamingRule","preserve") % ZoopDisplace

% select certain columns (check datetime,e type in raw data)
trophic=satellite(:,[3:5 7:9 21:23]);


% main analysis
cleantrophic=trophic(isnan(trophic.Chla)==0,:); % remove NA, which is no-overlapped sampling
% spearman's rank coefficient
[rho,pval]=corr(cleantrophic.ano_nitra,cleantrophic.Chla,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux\'
import lsqfitgm.*
[m,b,r,sm,sb]=lsqfitgm(cleantrophic.ano_nitra,cleantrophic.Chla); 
% [m_long,b_long,r_long,sm_long,sb_long]=lsqfitgm(cleantrophic.ano_nitra(find(cleantrophic.rlduration>=10)),cleantrophic.Chla(find(cleantrophic.rlduration>=10))); 
% [m_short,b_short,r_short,sm_short,sb_short]=lsqfitgm(cleantrophic.ano_nitra(find(cleantrophic.rlduration<10)),cleantrophic.Chla(find(cleantrophic.rlduration<10))); 

figure('Position',[50 50 1000 500])
subplot(1,2,1)
scatter(cleantrophic.ano_nitra,cleantrophic.Chla,50,cleantrophic.anoSST,'filled')
hold on
plot([min(cleantrophic.ano_nitra) max(cleantrophic.ano_nitra)],[min(cleantrophic.ano_nitra) max(cleantrophic.ano_nitra)]*m+b,'-k')
xlabel('Nitracline Anomaly','FontSize',16)
ylabel('Surface Chl Anomaly','FontSize',16)
title('Intensity')
colorbar
set(gca,'box','on')
set(gca,'ColorScale','log')

subplot(1,2,2)
scatter(cleantrophic.ano_nitra,cleantrophic.Chla,50,cleantrophic.rlduration,'filled')
hold on
plot([min(cleantrophic.ano_nitra) max(cleantrophic.ano_nitra)],[min(cleantrophic.ano_nitra) max(cleantrophic.ano_nitra)]*m+b,'-k')
xlabel('Nitracline Anomaly','FontSize',16)
ylabel('Surface Chl Anomaly','FontSize',16)
title('Duration')
colorbar
set(gca,'box','on')
set(gca,'ColorScale','log')

% main figure (Fig 6)
[m,b,r,sm,sb]=lsqfitgm(log10(satellite.anoSST),satellite.ano_nitra); 
[rho,pval] = corr(satellite.anoSST,satellite.ano_nitra,'Type','Spearman')

fighandle = figure(51);
fighandle.Units = 'inches';
fighandle.Position = [1 1 7.5 3];

set(gcf,'Units','Inches')
subplot(1,2,1)
plot(satellite.anoSST,satellite.ano_nitra,'.k')
hold on
scatter(cleantrophic.anoSST,cleantrophic.ano_nitra,50,cleantrophic.Chla,'filled')
hold on
%plot([min(cleantrophic.ano_nitra) max(cleantrophic.ano_nitra)],[min(cleantrophic.ano_nitra) max(cleantrophic.ano_nitra)]*m+b,'-k')
xlabel('SD-Intensity (^oC anomaly/SD)','FontSize',16)
ylabel(['Nitracline Anomaly'],'FontSize',16)
h=colorbar;
set(gca,'box','on')
set(gca,'XScale','log')
%set(gca,'ColorScale','log')
%set(h,'title','fucoxanthin anomaly')
colorTitleHandle = get(h,'Title');
set(colorTitleHandle ,'String',['SurfaceChl_a_n_o_m'],'Fontsize',12);
text(1.2,-2.3,['Spearmans \rho = ',num2str(rho,2),', p = ',num2str(pval,2)],'FontSize',14)



[m,b,r,sm,sb]=lsqfitgm(log10(satellite.rlduration),satellite.ano_nitra); 
[rho,pval] = corr(satellite.rlduration,satellite.ano_nitra,'Type','Spearman')

subplot(1,2,2)
plot(satellite.rlduration,satellite.ano_nitra,'.k')

hold on
scatter(cleantrophic.rlduration,cleantrophic.ano_nitra,50,cleantrophic.Chla,'filled')
hold on
% plot([min(satellite.rlduration):max(satellite.rlduration)],log10([min(satellite.rlduration):max(satellite.rlduration)])*m+b,'-k')
xlabel('Duration (days)','FontSize',16)
ylabel(['Nitracline Anomaly'],'FontSize',16)
h=colorbar
set(gca,'box','on')
set(gca,'XScale','log')
%set(gca,'ColorScale','log')
%set(h,'title','fucoxanthin anomaly')
colorTitleHandle = get(h,'Title');
set(colorTitleHandle ,'String',['SurfaceChl_a_n_o_m'],'FontSize',12);
tmp = turbo;
colormap(tmp(10:end-30,:))
text(1.06,-2.25,['Spearmans \rho = ',num2str(rho,2),', p = ',num2str(pval,2)],'FontSize',14)

cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\maunscript\MHW-bio\MHWbio-figure\Correlation')
fn = 'trophic_nitra_satellite'
exportgraphics(gcf,['',fn,'.png'],'Resolution',600)
