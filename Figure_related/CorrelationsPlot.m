% Plot the significant corrlations of each variable and MHW characterisitcs
% (fig 5)
clearvars
close all

addpath '../../../../../../../../Misc Oceanography/Matlab Functions/'
addpath 'C:\Users\Tz-Chian Chen\OneDrive - Florida State University\matlab&linux\djangraw\FormatFigures'

% import data (make sure which form is used. 'Reborn' for original anomaly, and 'std0410'for std anomaly)
Intensity = readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results\Statistics_MHWbio_Ori0423.xlsx','Sheet','OriIntensity_south');
Duration = readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\statistical_results\Statistics_MHWbio_Ori0423.xlsx','Sheet','OriDuration_south');

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
phy_inds = [1:5,11:13,17:20,21,23,24];
zoop_inds = 25:35;
fish_inds = 36:39;


fighandle = figure('pos',[10000 10000 10000 10000]);
fighandle.Units = 'inches';
fighandle.Position = [1 1 3.5 3.5];
hold on
plot(abs(Intensity.Rho(phy_inds)),abs(Duration.Rho(phy_inds)),'ok','MarkerFaceColor',[0.5 0.5 1],'MarkerSize',5)
plot(abs(Intensity.Rho(zoop_inds)),abs(Duration.Rho(zoop_inds)),'ok','MarkerFaceColor',[1 0.5 0.5],'MarkerSize',5)
plot(abs(Intensity.Rho(fish_inds)),abs(Duration.Rho(fish_inds)),'ok','MarkerFaceColor',[0.5 1 0.5],'MarkerSize',5) 
significant = union(find(Duration.pval<0.05),find(Intensity.pval<0.05));
phy_inds = intersect(significant,phy_inds);
zoop_inds = intersect(significant,zoop_inds);
fish_inds = intersect(significant,fish_inds);
for i=1:length(phy_inds)
    if ismember(i,1:3)
        plot(abs(Intensity.Rho(phy_inds(i))),abs(Duration.Rho(phy_inds(i))),'^k','MarkerFaceColor',[0 0 1],'MarkerSize',10)
    elseif i==length(phy_inds)
        plot(abs(Intensity.Rho(phy_inds(i))),abs(Duration.Rho(phy_inds(i))),'pentagramk','MarkerFaceColor',[0 0 1],'MarkerSize',12)
    else
        plot(abs(Intensity.Rho(phy_inds(i))),abs(Duration.Rho(phy_inds(i))),'vk','MarkerFaceColor',[0 0 1],'MarkerSize',10)
    end
end
for i=1:length(zoop_inds)
    if i==1
        plot(abs(Intensity.Rho(zoop_inds(i))),abs(Duration.Rho(zoop_inds(i))),'pentagramk','MarkerFaceColor',[1 0 0],'MarkerSize',12)
    else
        plot(abs(Intensity.Rho(zoop_inds(i))),abs(Duration.Rho(zoop_inds(i))),'vk','MarkerFaceColor',[1 0 0],'MarkerSize',10)
    end
end

plot(abs(Intensity.Rho(fish_inds)),abs(Duration.Rho(fish_inds)),'vk','MarkerFaceColor',[0 1 0],'MarkerSize',10)
plot([0 0.4],[0 0.4],':k')
for i=1:length(phy_inds)  % locate the text labels 
    if phy_inds(i)==4
        text(abs(Intensity.Rho(phy_inds(i)))-0.01,abs(Duration.Rho(phy_inds(i)))+0.015,Duration.Labels(phy_inds(i)),'FontSize',11)
    else
        text(abs(Intensity.Rho(phy_inds(i)))-0.02,abs(Duration.Rho(phy_inds(i)))+0.015,Duration.Labels(phy_inds(i)),'FontSize',11)
    end
end
for i=1:length(zoop_inds)
%     if i==1
%         text(abs(Intensity.Rho(zoop_inds(i)))-0.02,abs(Duration.Rho(zoop_inds(i)))+0.015,Duration.Labels(zoop_inds(i)),'FontSize',7)
%     elseif i==length(zoop_inds)-1
%          text(abs(Intensity.Rho(zoop_inds(i)))-0.04,abs(Duration.Rho(zoop_inds(i)))+0.015,Duration.Labels(zoop_inds(i)),'FontSize',7)
    if i==length(zoop_inds)-1
         text(abs(Intensity.Rho(zoop_inds(i)))-0.01,abs(Duration.Rho(zoop_inds(i)))+0.015,Duration.Labels(zoop_inds(i)),'FontSize',11)
    else
        text(abs(Intensity.Rho(zoop_inds(i)))-0.035,abs(Duration.Rho(zoop_inds(i)))+0.015,Duration.Labels(zoop_inds(i)),'FontSize',11)
    end

end
for i=1:length(fish_inds) % fish
    if i==1
         text(abs(Intensity.Rho(fish_inds(i)))-0.01,abs(Duration.Rho(fish_inds(i)))+0.015,Duration.Labels(fish_inds(i)),'FontSize',11)
    elseif i==length(fish_inds)-1
        text(abs(Intensity.Rho(fish_inds(i)))-0.01,abs(Duration.Rho(fish_inds(i)))+0.015,Duration.Labels(fish_inds(i)),'FontSize',11)
    elseif i==length(fish_inds)
        text(abs(Intensity.Rho(fish_inds(i)))-0.01,abs(Duration.Rho(fish_inds(i)))+0.015,Duration.Labels(fish_inds(i)),'FontSize',11)
    end

end
xlabel('Abs Correlation with SD-Intensity','FontSize',14)
ylabel('Abs Correlation with Duration','FontSize',14)
set(gca,'box','on','Fontsize',14)
h=legend({'Microbes (n.s.)';'Zooplankton (n.s.)';'Fish (n.s.)';'Intensity (sig)';'Duration (sig)';'Both characteristics (sig)'},'Location','Best')
ylim([0 0.4])
xlim([0 0.4])
% MakeLegend2([0.19 0.345; 0.005 0.08],['o','o','o','o','o','o'],flipud([0.7 0.7 1; 1 0.7 0.7; 0 0 1; 1 0 0]),...
%     flipud({'Microbes (n.s.)';'Zooplankton (n.s.)';'Fish (sig)';'Microbes (sig)';'Metazoan Zooplankton (sig)';'Fish (sig)'}),fliplr([5 5 10 10]),8 )
fn = 'CorrelationsPlot'
exportgraphics(gcf,['',fn,'.png'],'Resolution',600)
title('MHW characteristics correlation - suggestion')

%set(h,'FontSize',8)