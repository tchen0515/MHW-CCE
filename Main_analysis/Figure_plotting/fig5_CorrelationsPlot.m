% Plot the significant corrlations of each variable and MHW characterisitcs
% (fig 5) 
clearvars
close all

% import the combined sheet of statistical results
cd('MHW-CCE/Main_analysis/file')
Intensity=readtable('Statistics_MHWbio_final.xlsx','UseExcel',true,'Sheet','OriIntensity_south',VariableNamingRule='preserve');
Duration=readtable('Statistics_MHWbio_final.xlsx','UseExcel',true,'Sheet','OriDuration_south',VariableNamingRule='preserve');


Duration.Labels = Duration.Index;
Duration.Labels(find(strcmp(Duration.Index,'absChlalow1um'))) = {'Chl <1um'};
Duration.Labels(find(strcmp(Duration.Index,'absChla1-3um'))) = {'Chl 1-3um'};
Duration.Labels(find(strcmp(Duration.Index,'absChla3-8um'))) = {'Chl 3-8um'};
Duration.Labels(find(strcmp(Duration.Index,'absChla8-20um'))) = {'Chl 8-20um'};
Duration.Labels(find(strcmp(Duration.Index,'absChlaLarger20um'))) = {'Chl >20um'};
Duration.Labels(find(strcmp(Duration.Index,'SatelliteChla-2'))) = {'Surface Chl'};
Duration.Labels(find(strcmp(Duration.Index,'SatelliteChla-negmost'))) = {'Surface Chl'};
Duration.Labels(find(strcmp(Duration.Index,'IntChla'))) = {'VertInt Chl'};
Duration.Labels(find(strcmp(Duration.Index,'IntPP'))) = {'NPP'};
Duration.Labels(find(strcmp(Duration.Index,'ZooDisplace'))) = {'Zooplankton Vol'};
Duration.Labels(find(strcmp(Duration.Index,'oithona-like'))) = {'Oithona'};
Duration.Labels(find(strcmp(Duration.Index,'Sardine'))) = {'Sardine Eggs'};
Duration.Labels(find(strcmp(Duration.Index,'Anchovy'))) = {'Anchovy Eggs'};
Duration.Labels(find(strcmp(Duration.Index,'Sardine-larvae'))) = {'Sardine Larvae'};
Duration.Labels(find(strcmp(Duration.Index,'Anchovy-larvae'))) = {'Anchovy Larvae'};

% select the targeted variables

phy_inds = 2:16;
zoop_inds = 17:27;
fish_inds = 28:31;
nitra_inds = 1;

fighandle = figure('pos',[1000 1000 1000 1000]);
fighandle.Units = 'inches';
fighandle.Position = [1 1 3.5 3.5];
hold on
plot(abs(Intensity.Rho(phy_inds)),abs(Duration.Rho(phy_inds)),'ok','MarkerFaceColor',[0 0 1],'MarkerSize',5)
plot(abs(Intensity.Rho(zoop_inds)),abs(Duration.Rho(zoop_inds)),'ok','MarkerFaceColor',[1 0 0],'MarkerSize',5)
plot(abs(Intensity.Rho(fish_inds)),abs(Duration.Rho(fish_inds)),'ok','MarkerFaceColor',[0 1 0],'MarkerSize',5) 
plot(abs(Intensity.Rho(nitra_inds)),abs(Duration.Rho(nitra_inds)),'ok','MarkerFaceColor',[1 1 0],'MarkerSize',5)
significant = union(find(Duration.pval<0.05),find(Intensity.pval<0.05));
phy_inds = intersect(significant,phy_inds);
zoop_inds = intersect(significant,zoop_inds);
fish_inds = intersect(significant,fish_inds);
for i=1:length(phy_inds)
    if i==1
        plot(abs(Intensity.Rho(phy_inds(i))),abs(Duration.Rho(phy_inds(i))),'pentagramk','MarkerFaceColor',[0 0 1],'MarkerSize',12)
    elseif i==length(phy_inds)
        plot(abs(Intensity.Rho(phy_inds(i))),abs(Duration.Rho(phy_inds(i))),'vk','MarkerFaceColor',[0 0 1],'MarkerSize',12)
    else
        plot(abs(Intensity.Rho(phy_inds(i))),abs(Duration.Rho(phy_inds(i))),'^k','MarkerFaceColor',[0 0 1],'MarkerSize',12)
    end
end
for i=1:length(zoop_inds)
    if i==1
        plot(abs(Intensity.Rho(zoop_inds(i))),abs(Duration.Rho(zoop_inds(i))),'vk','MarkerFaceColor',[1 0 0],'MarkerSize',12)
    else
        plot(abs(Intensity.Rho(zoop_inds(i))),abs(Duration.Rho(zoop_inds(i))),'pentagramk','MarkerFaceColor',[1 0 0],'MarkerSize',12)
    end
end

%plot(abs(Intensity.Rho(fish_inds)),abs(Duration.Rho(fish_inds)),'vk','MarkerFaceColor',[0 1 0],'MarkerSize',10)
plot([0 0.4],[0 0.4],':k')
for i=1:length(phy_inds)  % locate the text labels 
    if phy_inds(i)==4
        text(abs(Intensity.Rho(phy_inds(i)))-0.01,abs(Duration.Rho(phy_inds(i)))+0.015,Duration.Labels(phy_inds(i)),'FontSize',11)
    else
        text(abs(Intensity.Rho(phy_inds(i)))-0.02,abs(Duration.Rho(phy_inds(i)))+0.015,Duration.Labels(phy_inds(i)),'FontSize',11)
    end
end
for i=1:length(zoop_inds)
    if i==length(zoop_inds)-1
         text(abs(Intensity.Rho(zoop_inds(i)))-0.01,abs(Duration.Rho(zoop_inds(i)))+0.015,Duration.Labels(zoop_inds(i)),'FontSize',11)
    else
        text(abs(Intensity.Rho(zoop_inds(i)))-0.035,abs(Duration.Rho(zoop_inds(i)))+0.015,Duration.Labels(zoop_inds(i)),'FontSize',11)
    end

end

xlabel('Correlation with SD-Intensity (Abs value)','FontSize',14)
ylabel('Correlation with Duration (Abs value)','FontSize',14)
set(gca,'box','on','Fontsize',14)
h=legend({'Microbes';'Zooplankton';'Fish';'Nitracline';'Intensity (sig)';'Duration (sig)';'Both characteristics (sig)'},'Location','Best')
ylim([0 0.4])
xlim([0 0.4])
fn = 'CorrelationsPlot'
exportgraphics(gcf,['',fn,'.png'],'Resolution',600)
title('MHW characteristics correlation')
