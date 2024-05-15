%%% plot barplot for Spearman's rank coef of biological data and nitracline
close all
clear all
% import main data
cd ('C:\Users\USER\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
nitraw=readtable('Statistics_MHWbio_Ori0423.xlsx','UseExcel',true,'Sheet','OriNutrient_south');
nitraw=nitraw([1:8 13:15 9:12],:);

% barplot 
p1=figure('pos',[10 55 20000 10000])
% subplot(6,6,[1:3 7:9 13:15])
x1=categorical(nitraw.Index);
x1=reordercats(x1,{'SatelliteChla','VerIntChla','VerIntPP',...
'Chla<1um','Chla1-3um','Chla3-8um','Chla8-20um','Chla>20um',...
'Divinyl Chla','Fucoxanthin','Hexanoyloxyfucox',...
'Prochlorococcus','Synechococcus','HeteroBacteria','Picoeukaryotes'}); 

y1=nitraw.Rho;
pval1=find(nitraw.pval<0.05); % which index show significance
b1=bar(x1,y1);
b1.FaceColor='flat';
b1.CData(pval1,:)=[1 0 0;1 0 0;1 0 0;1 0 0]; % hue (confirm the length of pval)
set(gca,'fontsize', 15,'fontweight','bold','xticklabel',{'SurfaceChla','VerIntChla','VerIntPP',...
'Chla<1um','Chla1-3um','Chla3-8um','Chla8-20um','Chla>20um',...
'Divinyl Chla','Fucoxanthin','Hexanoyloxyfucoxanthin',...
'Prochlorococcus','Synechococcus','HeteroBacteria','Picoeukaryotes'}) 
yline(0,'linew',2)
ylim ([-0.5 0.35])
% xticks([])
yticks([-0.5:0.2:0.35])
ylabel("Correlation Coefficient(Rho)")
% title('Nitracline versus Short-lived microbes');
