%%% plot barplot for Spearman's rank coef of each bio-index
close all
clear all
% import main data
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results')
% seperately sheets by MHW characteristics
mhwmag=readtable('Statistics_MHWbio_Ori0423.xlsx','UseExcel',true,'Sheet','OriIntensity_south');
mhwdur=readtable('Statistics_MHWbio_Ori0423.xlsx','UseExcel',true,'Sheet','OriDuration_south');

% seperate bio-indexes by taxa
phytomag=mhwmag([40 21 23 24 1:5 11:13 18 19 17 20],:); % exclude satellite NPP & reorder taxa
zoomag=mhwmag([35 25:28 31 30 29 32:34 36:39],:); % only select specific taxa 
phytodur=mhwdur([40 21 23 24 1:5 11:13 18 19 17 20],:);  
zoodur=mhwdur([35 25:28 31 30 29 32:34 36:39],:);

% barplot for phyto_intensity
p1=figure('pos',[10 55 20000 10000])
% subplot(6,6,[1:3 7:9 13:15])
x1=categorical(phytomag.Index);
x1=reordercats(x1,{'Nitracline','SatelliteChla-negmost','IntChla','IntPP',...
'absChlalow1um','absChla1-3um','absChla3-8um','absChla8-20um','absChlaLarger20um',...
'Divinyl Chla','Fucoxanthin','Hexanoyloxyfucoxanthin',...
'Prochlorococcus','Synechococcus','HeteroBacteria','Picoeukaryotes'}); 

y1=phytomag.Rho;
pval1=find(phytomag.pval<0.05); % which index show significance
b1=bar(x1,y1);
b1.FaceColor='flat';
b1.CData(pval1,:)=[1 0 0;1 0 0;1 0 0;1 0 0]; % hue (confirm the length of pval)
set(gca,'fontsize', 15,'fontweight','bold','xticklabel',{'Nitracline','SatelliteChla','VerIntChla','VerIntPP',...
'Chla<1um','Chla1-3um','Chla3-8um','Chla8-20um','Chla>20um',...
'Divinyl Chla','Fucoxanthin','Hexanoyloxyfucoxanthin',...
'Prochlorococcus','Synechococcus','HeteroBacteria','Picoeukaryotes'})
yline(0,'linew',2)
ylim ([-0.4 0.4])
% xticks([])
yticks([-0.4:0.2:0.4])
ylabel("Rho")
title('(a) MHW SD-intensity versus Microbes & Nitracline');

% barplot for zoo_intensity
p2=figure('pos',[10 10 20000 10000])
% subplot(6,6,[4:6 10:12 16:18])
x2=categorical(zoomag.Index);
x2=reordercats(x2,{'ZooDisplace','calanoid','copepoda-eucalanids','copepoda-harpacticoida','copepoda-poecilostomatoids',...
    'oithona-like','nauplii','euphausiids','pyrosomes','salps','doliolids',...
    'Sardine','Anchovy','Sardine-larvae','Anchovy-larvae'});
y2=zoomag.Rho;
pval2=find(zoomag.pval<0.05); % which index show significance
b2=bar(x2,y2);
b2.CData(pval2,:)=[1 0 0];
b2.FaceColor='flat';
set(gca,'fontsize', 15,'fontweight','bold','xticklabel',{'ZDV','Calanoid','Eucalanids','Harpacticoida','Poecilostomatoids',...
     'Oithona','Nauplii','Euphausiids','Pyrosomes','Salps','Doliolids',...
     'Sardine Egg','Anchovy Egg','Sardine Larvae','Anchovy Larvae'});
ylim ([-0.4 0.4])
% xticks([])
yline(0,'linew',2)
yticks([-0.4:0.2:0.4])
ylabel("Rho")
title('(b) MHW intensity versus Zooplankton & Fish')

% barplot for phyto_duration
p3=figure('pos',[10 10 20000 10000])
% subplot(6,6,[19:21 25:27 31:33])
x3=categorical(phytodur.Index);
x3=reordercats(x3,{'Nitracline','SatelliteChla-negmost','IntChla','IntPP',...
'absChlalow1um','absChla1-3um','absChla3-8um','absChla8-20um','absChlaLarger20um',...
'Divinyl Chla','Fucoxanthin','Hexanoyloxyfucoxanthin',...
'Prochlorococcus','Synechococcus','HeteroBacteria','Picoeukaryotes'}); 
y3=phytodur.Rho;
pval3=find(phytodur.pval<0.05); % which index show significance
b3=bar(x3,y3);
b3.FaceColor='flat';
b3.CData(pval3,:)=[1 0 0;1 0 0]; % hue (confirm the length of pval)
set(gca,'fontsize', 15,'fontweight','bold','xticklabel',{'Nitracline','SatelliteChla','VerIntChla','VerIntPP',...
    'Chla<1um','Chla1-3um','Chla3-8um','Chla8-20um','Chla>20um',...
      'Divinyl Chla','Fucoxanthin','Hexanoyloxyfucoxanthin',...
    'Prochlorococcus','Synechococcus','HeteroBacteria','Picoeukaryotes'})
yline(0,'linew',2)
ylim ([-0.4 0.4])
yticks(-0.4:0.2:0.4)
ylabel("Rho")
title('(c) MHW duration versus Short-lived microbes')

% barplot for zoo_duration
p4=figure('pos',[10 10 20000 10000])
% subplot(6,6,[22:24 28:30 34:36])
x4=categorical(zoodur.Index);
x4=reordercats(x4,{'ZooDisplace','calanoid','copepoda-eucalanids','copepoda-harpacticoida','copepoda-poecilostomatoids',...
    'oithona-like','nauplii','euphausiids','pyrosomes','salps','doliolids',...
    'Sardine','Anchovy','Sardine-larvae','Anchovy-larvae'});
y4=zoodur.Rho;
pval4=find(zoodur.pval<0.05); % which index show significance
b4=bar(x4,y4);
b4.FaceColor='flat';
b4.CData(pval4,:)=[1 0 0;1 0 0]; % hue (confirm the length of pval)
set(gca,'fontsize', 15,'fontweight','bold','xticklabel',{'ZDV','Calanoid','Eucalanids','Harpacticoida','Poecilostomatoids',...
    'Oithona-like','Nauplii','Euphausiids','Pyrosomes','Salps','Doliolids',...
    'Sardine Egg','Anchovy Egg','Sardine Larvae','Anchovy Larvae'});
yline(0,'linew',2)
ylim([-0.4 0.4])
yticks(-0.4:0.2:0.4)
ylabel("Rho")
title('(d) MHW duration versus Zooplankton & Fish')


% % trophic relationship
% p2=figure(5)
% x5=categorical(mhwtro.prey_index([1:4]));
% x5=categorical({'Chla-20um','IntChla','SatelliteChla','fucoxanthin'});
% y5=mhwtro.Rho([1:4]);
% pval5=find(mhwtro.pval([1:4])<0.05); % which index show significance
% b5=bar(x5,y5);
% b5.FaceColor='flat';
% b5.CData(pval5,:)=[1 0 0];
% set(gca,'fontsize', 20,'fontweight','bold','xticklabel',{'Chla>20um','VerIntChla','SatelliteChla','Fucoxanthin'});
% ylim auto
% ylabel("Rho")
% title('trophic relationship ~ zooplankton')

%save figure
cd('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\mhwbio_figure\Rho')
savefig(p1,'all_characteristics_231215.fig')
savefig(p2,'trophic_zooVolume.fig')