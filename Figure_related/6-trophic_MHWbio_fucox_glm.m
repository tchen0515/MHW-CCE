%%% write a table for cascading trophic interaction analysis (zoo-Fucoxanthin)
clear all
close all
% import data (Final_MHW)
cd('...')
zoo = readtable("OriFinal_MHW_ZooDisplace.csv","VariableNamingRule","preserve") % ZoopDisplace
Fucoxanthin = readtable("OriFinal_MHW_HPLC.csv","VariableNamingRule","preserve") % Fucoxanthinanthin
cd('...')
mashup=readtable('MHW-in situ data.xlsx','UseExcel',true,'Sheet','Data Table (1)');
mashup.Fucoxanthin=str2double(mashup.Fucoxanthin);
mashup.ZooDisplace=str2double(mashup.ZooDisplace);

trophic=mashup(isnan(mashup.Fucoxanthin)==0,:);
trophic.ZooAno=trophic.ZooDisplace;


% main analysis
cleantrophic=trophic(isnan(trophic.ZooAno)==0,:); % remove NA, which is no-overlapped sampling
% spearman's rank coefficient
[rho,pval]=corr(cleantrophic.Fucoxanthin,cleantrophic.ZooAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
cd('...\matlab&linux\')
import lsqfitgm.*
[m,b,r,sm,sb]=lsqfitgm(cleantrophic.Fucoxanthin,cleantrophic.ZooAno); 

%intensity subplot
[m,b,r,sm,sb]=lsqfitgm(log10(zoo.anoSST),zoo.Anomaly); 
[rho,pval] = corr(zoo.anoSST,zoo.Anomaly,'Type','Spearman')

fighandle = figure(51);
fighandle.Units = 'inches';
fighandle.Position = [1 1 7.5 3];

set(gcf,'Units','Inches')
subplot(1,2,1)
plot(zoo.anoSST,zoo.Anomaly,'.k')
hold on
scatter(cleantrophic.anoSST,cleantrophic.ZooAno,60,cleantrophic.Fucoxanthin,'filled')
hold on
%plot([min(cleantrophic.Fucoxanthin) max(cleantrophic.Fucoxanthin)],[min(cleantrophic.Fucoxanthin) max(cleantrophic.Fucoxanthin)]*m+b,'-k')
xlabel('SD-Intensity (^oC anomaly/SD)','FontSize',18)
ylabel(['Zooplankton Displacement',char(10),'Volume Anomaly'],'FontSize',18)
h=colorbar;
set(gca,'box','on')
set(gca,'XScale','log')
%set(gca,'ColorScale','log')
%set(h,'title','Fucoxanthinanthin anomaly')
colorTitleHandle = get(h,'Title');
set(colorTitleHandle ,'String',['Fucoxanthin_a_n_o_m'],'Fontsize',14);
text(1.1,-1.35,['Spearmans \rho = ',num2str(rho,2),', p = ',num2str(pval,2)],'FontSize',14)

%duration subplot
[m,b,r,sm,sb]=lsqfitgm(log10(zoo.rlduration),zoo.Anomaly); 
[rho,pval] = corr(zoo.rlduration,zoo.Anomaly,'Type','Spearman')

subplot(1,2,2)
plot(zoo.rlduration,zoo.Anomaly,'.k')

hold on
scatter(cleantrophic.rlduration,cleantrophic.ZooAno,60,cleantrophic.Fucoxanthin,'filled')
hold on
%plot([min(zoo.rlduration):max(zoo.rlduration)],log10([min(zoo.rlduration):max(zoo.rlduration)])*m+b,'-k')
xlabel('Duration (days)','FontSize',18)
ylabel(['Zooplankton Displacement',char(10),'Volume Anomaly'],'FontSize',18)
h=colorbar
set(gca,'box','on')
set(gca,'XScale','log')
colorTitleHandle = get(h,'Title');
set(colorTitleHandle ,'String',['Fucoxanthin_a_n_o_m'],'FontSize',14);
tmp = turbo;
colormap(tmp(10:end-30,:))
text(1.05,-1.35,['Spearmans \rho = ',num2str(rho,2),', p = ',num2str(pval,2)],'FontSize',14) %char(10),'ZDV_a = ',num2str(m,2),' * log_1_0(dur) + ',num2str(b,2)]

cd('...')
fn = 'trophic_MHWbio_Fucoxanthin'
exportgraphics(gcf,['',fn,'.png'],'Resolution',600)

