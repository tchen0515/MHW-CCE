%%% plot barplot for Spearman's rank coef of each bio-index
close all
clear all

% import the combined sheet of statistical results
cd('MHW-CCE/file/')
mhwmag=readtable('Statistics_MHWbio_final.xlsx','UseExcel',true,'Sheet','OriIntensity_south',VariableNamingRule='preserve');
mhwdur=readtable('Statistics_MHWbio_final.xlsx','UseExcel',true,'Sheet','OriDuration_south',VariableNamingRule='preserve');

% seperate bio-indexes by taxa
phytomag=mhwmag(1:16,:);
zoomag=mhwmag(17:31,:); 
phytodur=mhwdur(1:16,:);  
zoodur=mhwdur(17:31,:);

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
