clearvars
close all

for i=1:9
    if i==1
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_ZooDisplace.csv');
        ano = data.Anomaly;
        TITLE = 'Zooplankton Displacement Volume'
        duration = data.rlduration;
    elseif i==2
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\MHWOccurrence_largestChla.csv');
        ano = data.Chla;
        TITLE = 'Surface Chlorophyll'
        duration = data.mhw_dur;
        data.anoSST = data.int_max;
    elseif i==3
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_Chla_trape.csv');
        ano = data.Chla;
        TITLE = 'Bottle Chlorophyll'
        duration = data.rlduration;
        
    elseif i==4
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_SizeFraction.csv');
        %ano = data.Chla_8um;
        ano = data.Chla8_20um; 
        TITLE = 'Size Frac 8-20'
        duration = data.rlduration; 
        
    elseif i==5
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_SizeFraction.csv');
        %ano = data.Chla_20um;
        ano = data.Chlalarge20um;
        TITLE = 'Size Frac G20'
        duration = data.rlduration; 
    elseif i==6
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_SizeFraction.csv');
        %ano = data.Chla_Chla_1um;
        ano = data.Chlalower1um;
        TITLE = 'Size Frac L1'
        duration = data.rlduration; 
    elseif i==7
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_HPLC.csv');
        %ano = data.Chla_Chla_1um;
        ano = data.fucox;
        TITLE = 'Fucoxanthin'
        duration = data.rlduration; 
    elseif i==8
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_YJ_FishEgg.csv');
        data(find(data.sardine==0),:)=[];
        data(find(abs(data.sardine)<10^-8),:)=[];
        ano = data.sardine;
        TITLE = 'Sardine Eggs'
        duration = data.rlduration; 
    elseif i==9
        data=readtable('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Output\output_mhwbio\Final_MHW_PicoBacteria_aver10m.csv');
        ano = data.Prochlorococcus;
        TITLE = 'Prochlorococcus'
        duration = data.rlduration; 
    end
    intensity = data.anoSST;
    dt = datetime;

    figure(i)
    set(gcf,'Position',[50 50 2000 500])
    subplot(1,4,1)
    scatter(intensity,duration,50,ano,'filled')
    xlabel('intensity')
    ylabel('duration')
    colormap(turbo)
    colorbar
    set(gca,'box','on')
    title(TITLE)

    subplot(1,4,2)
    ind = find(isnan(ano)==0);
    scatter(intensity,ano,50,duration,'filled')
    xlabel('intensity')
    ylabel('transformed anomaly')
    colormap(parula)
    colorbar
    set(gca,'box','on')
    x=get(gca,'XLim');
    y=get(gca,'YLim');
    [rho,pval]=corr(intensity(ind),ano(ind),'type','Spearman')
    text(0.6*x(1) + 0.4*x(2), 0.05*y(1) + 0.95*y(2), ['\rho = ',num2str(rho,2),char(10),'p = ',num2str(pval,3)])
    title(TITLE)
    set(gca,'XScale','Log')
    set(gca,'ColorScale','log')

    subplot(1,4,3)
    scatter(duration,ano,50,intensity,'filled')
    xlabel('duration')
    ylabel('transformed anomaly')
    colormap(parula)
    colorbar
    set(gca,'box','on')
    x=get(gca,'XLim');
    y=get(gca,'YLim');
    [rho,pval]=corr(duration(ind),ano(ind),'type','Spearman')
    text(0.6*x(1) + 0.4*x(2), 0.05*y(1) + 0.95*y(2), ['\rho = ',num2str(rho,2),char(10),'p = ',num2str(pval,3)])
    title(TITLE)
    set(gca,'XScale','Log')
    set(gca,'ColorScale','log')

    subplot(2,4,4)
    ind = find(intensity<2);
    [N,edges] = histcounts(ano(ind));
    N = N/sum(N)/(edges(2)-edges(1));
    plot((edges(2:end)+edges(1:end-1))/2,N)
    hold on
    ind = find(intensity>=2);
    [N,edges] = histcounts(ano(ind),edges);
    N = N/sum(N)/(edges(2)-edges(1));
    plot((edges(2:end)+edges(1:end-1))/2,N)
    title('Histograms split on intensity')

    subplot(2,4,8)
    ind = find(duration<10);
    [N,edges] = histcounts(ano(ind));
    N = N/sum(N)/(edges(2)-edges(1));
    plot((edges(2:end)+edges(1:end-1))/2,N)
    hold on
    ind = find(duration>=10);
    [N,edges] = histcounts(ano(ind),edges);
    N = N/sum(N)/(edges(2)-edges(1));
    plot((edges(2:end)+edges(1:end-1))/2,N)
    title('Histograms split on duration')

    figure(538)
    [b,bint,r,rint,stats] = regress(ano(ind),[intensity(ind),duration(ind),ones(size(duration(ind)))]);
    plot(b(1),b(2),'ok')
    hold on
    text(b(1),b(2),TITLE)
    xlabel('Intensity coefficient')
    ylabel('Duration coefficient')
    

    %f_rdaDB(ano(ind),[intensity(ind),duration(ind)],0)

    clearvars
end