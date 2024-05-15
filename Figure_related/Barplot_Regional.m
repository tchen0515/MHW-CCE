%%% plot barplot for Spearman's rank coef of Regional subset data
close all
clear all
% import main data
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
mhwraw=readtable('Statistics_MHWbio_Ori0423.xlsx','UseExcel',true,'Sheet','Oriregionsub');

% seperate intensity and duration datasheet
subint = mhwraw([1 6 2 7 3 8 4 9 5 10],["Index" "Size" "int_Rho" "int_pval"]);
subdur = mhwraw([1 6 2 7 3 8 4 9 5 10],["Index" "Size" "dur_Rho" "dur_pval"]);

%% Barplot

% intensity
p1=figure('pos',[10 55 20000 10000])
% subplot(6,6,[1:3 7:9 13:15])
x1=categorical(subint.Index);
x1=reordercats(x1,{'uSatelliteChla','S_SatelliteChla','uIntChla','S_IntChla',...
'uZDV','S_ZDV','uSardineEgg','S_SardineEgg','uAnchovyEgg','S_AnchovyEgg'}); 

y1=subint.int_Rho;
pval1=find(subint.int_pval<0.05); % which index show significance
b1=bar(x1,y1);
b1.FaceColor='flat';
b1.CData(pval1,:)=[1 0 0;1 0 0;1 0 0]; % hue (confirm the length of pval)
set(gca,'fontsize', 16,'fontweight','bold','xticklabel',{'N-SurfaceChla','S-SurfaceChla','N-VerIntChla',...
    'S-VerIntChla','N-ZDV','S-ZDV','N-SardineEgg','S-SardineEgg','N-AnchovyEgg','S-AnchovyEgg'})
yline(0,'linew',2)
ylim ([-0.45 0.45])
% xticks([])
yticks([-0.45:0.2:0.45])
ylabel("Correlation Coefficient (Rho)")
title('(a) MHW SD-intensity');

% duration
p2=figure('pos',[10 55 20000 10000])
% subplot(6,6,[1:3 7:9 13:15])
x2=categorical(subdur.Index);
x2=reordercats(x2,{'uSatelliteChla','S_SatelliteChla','uIntChla','S_IntChla',...
'uZDV','S_ZDV','uSardineEgg','S_SardineEgg','uAnchovyEgg','S_AnchovyEgg'}); 

y2=subdur.dur_Rho;
pval2=find(subdur.dur_pval<0.05); % which index show significance
b2=bar(x2,y2);
b2.FaceColor='flat';
b2.CData(pval2,:)=[1 0 0;1 0 0;1 0 0;1 0 0;1 0 0]; % hue (confirm the length of pval)
set(gca,'fontsize', 16,'fontweight','bold','xticklabel',{'N-SurfaceChla','S-SurfaceChla','N-VerIntChla',...
    'S-VerIntChla','N-ZDV','S-ZDV','N-SardineEgg','S-SardineEgg','N-AnchovyEgg','S-AnchovyEgg'})
yline(0,'linew',2)
ylim ([-0.5 0.4])
% xticks([])
yticks([-0.5:0.2:0.4])
ylabel("Correlation Coefficient (Rho)")
title('(b) MHW duration');