clear all
close all
% import raw data & extract selected columns
cd ('C:\Users\Tz-Chian Chen\OneDrive - Florida State University\CalCOFI\Fish\')
raw = readtable('Fish from Andrew Thompson_wdates.csv',VariableNamingRule='preserve');
time=datevec(raw.Date);
bio=raw(:,[4 5 7 6 8 9]);
bio.Month=time(:,2);
bio.Day=time(:,3);
bio.sardine=raw.Sardinops_sagax;
bio.anchovy=raw.Engraulis_mordax;
bio.Properties.VariableNames = ["Line","Station","Latitude","Longitude","Year","Season",...
    "Month","Day","Sardine","Anchovy"];
ALLbio=bio(isnan(bio.Day)==0,:);

% convert season scale into number code
season=zeros(height(ALLbio),1);
for i=1:height(ALLbio)
        c=ALLbio.Season(i);
    if strcmp(c,'spring')
        season(i)=1;
    elseif strcmp(c,'summer')
        season(i)=2;
    elseif strcmp(c,'fall')
        season(i)=3;
    else strcmp(c,'winter')
        season(i)=4;
    end
end
bioall=[ALLbio(:,[1:5 7:end]) array2table(season)];
bioall.Properties.VariableNames = ["Line","Station","Latitude","Longitude","Year","Month","Day",...
    "sardine","anchovy","Season"];

writetable(bioall,'FishLarve1215.csv') % for doing YJ_trans in R
