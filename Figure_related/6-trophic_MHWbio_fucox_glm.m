%%% write a table for cascading trophic interaction analysis (zoo-fucox)
% require packagfe "lsqfitgm"
clear all
close all
% import data (Final_MHW)
cd('C:\Users\USER\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\OriBio-SDMHW\')
zoo = readtable("OriFinal_MHW_ZooDisplace.csv","VariableNamingRule","preserve") % ZoopDisplace
fucox = readtable("OriFinal_MHW_HPLC.csv","VariableNamingRule","preserve") % fucoxanthin

% select certain columns (check datetime,e type in raw data)
target = [fucox(:,[1:8 11 13 22 23 24])]; % fucox

% select the common sampling date & station
trophic=zeros(height(target),9);
for i=1:height(target)
    tf = any(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station);
    idx = find(target.datetime(i)==zoo.datetime&target.Line(i)==zoo.Line&target.Station(i)==zoo.Station); % same date & station
    if tf==0
        trophic(i,:)= [target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),NaN,NaN,target.fucox(i),NaN]
    else
        trophic(i,:)= [target.Year(i), target.Month(i), target.Day(i), target.Line(i), target.Station(i),...
            zoo.anoSST(idx), zoo.rlduration(idx), target.fucox(i), zoo.Anomaly(idx)]; %combine the zoo-phyto data
    end
end
trophic=array2table(trophic);
trophic.Properties.VariableNames=["Year","Month","Day","Line","Station",...
    "anoSST","Duration","fucox","ZooAno"];



% main analysis
cleantrophic=trophic(isnan(trophic.ZooAno)==0,:); % remove NA, which is no-overlapped sampling
% spearman's rank coefficient
[rho,pval]=corr(cleantrophic.fucox,cleantrophic.ZooAno,'type','Spearman')  
% rho: Pairwise linear correlation coefficient 
% pval: p-value

% Model II Geometric Mean Regression
cd('C:\Users\USER\OneDrive - Florida State University\matlab&linux\')
import lsqfitgm.*
[m,b,r,sm,sb]=lsqfitgm(cleantrophic.fucox,cleantrophic.ZooAno); 
% [m_long,b_long,r_long,sm_long,sb_long]=lsqfitgm(cleantrophic.fucox(find(cleantrophic.Duration>=10)),cleantrophic.ZooAno(find(cleantrophic.Duration>=10))); 
% [m_short,b_short,r_short,sm_short,sb_short]=lsqfitgm(cleantrophic.fucox(find(cleantrophic.Duration<10)),cleantrophic.ZooAno(find(cleantrophic.Duration<10))); 

figure('Position',[50 50 1000 500])
subplot(1,2,1)
scatter(cleantrophic.fucox,cleantrophic.ZooAno,50,cleantrophic.anoSST,'filled')
hold on
plot([min(cleantrophic.fucox) max(cleantrophic.fucox)],[min(cleantrophic.fucox) max(cleantrophic.fucox)]*m+b,'-k')
xlabel('Fucoxanthin Anomaly','FontSize',16)
ylabel('Zooplankton Displacement Volume Anomaly','FontSize',16)
title('Intensity')
colorbar
set(gca,'box','on')
set(gca,'ColorScale','log')

subplot(1,2,2)
scatter(cleantrophic.fucox,cleantrophic.ZooAno,50,cleantrophic.Duration,'filled')
hold on
plot([min(cleantrophic.fucox) max(cleantrophic.fucox)],[min(cleantrophic.fucox) max(cleantrophic.fucox)]*m+b,'-k')
xlabel('Fucoxanthin Anomaly','FontSize',18)
ylabel('Zooplankton Displacement Volume Anomaly','FontSize',18)
title('Duration')
colorbar
set(gca,'box','on')
set(gca,'ColorScale','log')

% main figure (Fig 6)
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
scatter(cleantrophic.anoSST,cleantrophic.ZooAno,60,cleantrophic.fucox,'filled')
hold on
%plot([min(cleantrophic.fucox) max(cleantrophic.fucox)],[min(cleantrophic.fucox) max(cleantrophic.fucox)]*m+b,'-k')
xlabel('SD-Intensity (^oC anomaly/SD)','FontSize',18)
ylabel(['Zooplankton Displacement',char(10),'Volume Anomaly'],'FontSize',18)
h=colorbar;
set(gca,'box','on')
set(gca,'XScale','log')
%set(gca,'ColorScale','log')
%set(h,'title','fucoxanthin anomaly')
colorTitleHandle = get(h,'Title');
set(colorTitleHandle ,'String',['Fucoxanthin_a_n_o_m'],'Fontsize',14);
text(1.1,-1.35,['Spearmans \rho = ',num2str(rho,2),', p = ',num2str(pval,2)],'FontSize',14)


%duration subplot
[m,b,r,sm,sb]=lsqfitgm(log10(zoo.rlduration),zoo.Anomaly); 
[rho,pval] = corr(zoo.rlduration,zoo.Anomaly,'Type','Spearman')

subplot(1,2,2)
plot(zoo.rlduration,zoo.Anomaly,'.k')

hold on
scatter(cleantrophic.Duration,cleantrophic.ZooAno,60,cleantrophic.fucox,'filled')
hold on
plot([min(zoo.rlduration):max(zoo.rlduration)],log10([min(zoo.rlduration):max(zoo.rlduration)])*m+b,'-k')
xlabel('Duration (days)','FontSize',18)
ylabel(['Zooplankton Displacement',char(10),'Volume Anomaly'],'FontSize',18)
h=colorbar
set(gca,'box','on')
set(gca,'XScale','log')
%set(gca,'ColorScale','log')
%set(h,'title','fucoxanthin anomaly')
colorTitleHandle = get(h,'Title');
set(colorTitleHandle ,'String',['Fucoxanthin_a_n_o_m'],'FontSize',14);
tmp = turbo;
colormap(tmp(10:end-30,:))
text(1.05,-1.35,['Spearmans \rho = ',num2str(rho,2),', p = ',num2str(pval,2), char(10),'ZDV_a = ',num2str(m,2),' * log_1_0(dur) + ',num2str(b,2)],'FontSize',14)

cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\maunscript\MHW-bio\MHWbio-figure\Correlation')
fn = 'trophic_MHWbio_fucox'
exportgraphics(gcf,['',fn,'.png'],'Resolution',600)

breakitty
%Generalized Additive Model

GAMtable = array2table([cleantrophic.anoSST,cleantrophic.Duration,cleantrophic.fucox,cleantrophic.ZooAno],'VariableNames',{'SST','Dur','Fuco','DisVol'});

Mdl = fitrgam(GAMtable,'DisVol','CategoricalPredictors',[],'Interactions',logical([1 1 0; 1 0 1; 0 1 1])); 

SST = 1.5;
dur = 0:30;
fuco = -1.5:0.1:0.5;
for i=1:length(dur)
    for j=1:length(fuco)

        pred_DV(i,j) = predict(Mdl,[SST,dur(i),fuco(j)]);

    end
end

figure('Position',[50 50 1000 500])
% subplot(1,2,1)
pcolor(dur,fuco,pred_DV')
xlabel('Duration')
ylabel('Fucoxanthin Anomaly')
title('Zooplankton Displacement Volume Anomaly')
colorbar
set(gca,'box','on','FontSize',16)

% subplot(1,2,2)
% scatter(cleantrophic.fucox,cleantrophic.ZooAno,50,cleantrophic.Duration,'filled')
% xlabel('Fucoxanthin Anomaly')
% ylabel('Zooplankton Displacement Volume Anomaly')
% title('Anomaly')
% colorbar
% set(gca,'box','on')

%LOESS Model

[B,FitInfo] = lasso([cleantrophic.anoSST,cleantrophic.Duration,cleantrophic.fucox],cleantrophic.ZooAno,'CV',10);

figure
yyaxis left
plot(log10(FitInfo.Lambda),FitInfo.MSE)
ind1 = FitInfo.IndexMinMSE;
ind2 = FitInfo.Index1SE;  %1 standard error greater than the minimum MSE
hold on
plot([log10(FitInfo.Lambda(ind1)),log10(FitInfo.Lambda(ind1))],[0,max(FitInfo.MSE)],':k')
plot([log10(FitInfo.Lambda(ind2)),log10(FitInfo.Lambda(ind2))],[0,max(FitInfo.MSE)],':k')
xlabel('log_1_0(lambda)')
ylabel('Mean Squared Error')
yyaxis right
plot(log10(FitInfo.Lambda),FitInfo.DF)
xlabel('NumVar')
optimummodel = B(:,ind2)
IncludedIndices = find(optimummodel~=0);
'Parameters Included = '
for i=1:length(IncludedIndices)
    GAMtable.Properties.VariableNames(IncludedIndices(i))
end
