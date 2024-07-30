# 3. Main analysis 
The main analysis script contain the codes for statistical tests and plotting main figures presented in the study. 

## 3.1 Statistical analysis 
These scripts give the statistical test results, including Spearman's rank coefficients and Model II regression, for the anomalies of each biological variable and MHW characteristics (intensity and duration). 

| Code                     | Description       |
|--------------------------|-------------------|
|Stdglm_MHW_ChlaPP.m       |   Satellite chlorophyll a concentration, net primary production, vertically integrated chlorophyll and Nitracline|
|Stdglm_MHW_HPLC.m         |  Phytoplankton taxon-specific pigments from High-Performance Liquid-Chromatography analysis           |
|Stdglm_MHW_PicoBacteria.m |   Flow cytometry of picoplankton and heterotrophic bacteria      |
|Stdglm_MHW_sizeFraction.m |      Size-fractionated chlorophyll a concentration        |
|Stdglm_MHW_ZooScan.m      |      Metazoan (zooplankton, fish egg, fish larvae)            |
|Stdglm_trophic_MHWbio.m   |      Trophic relationship of ZDV and selected prey variables             |


## 3.2 Figure plotting 
These scripts generate the main figures presented in the study. 
|       Code                             | Description  |
|----------------------------------------|--------------|
|Fig1_CalCOFI_map.m                      |Fig 1 (a & b): CalCOFI sampling region and the detection of MHW occurrence at the inshore and offshore station from 1982 to 2021|
|Fig2_mhw_heatmap.m                      |Fig 2: Heatmap of MHW characteristics|
|Fig3_Boxplot.m                          |Fig 3: Nutrient and biological anomalies during MHW events and the statistical result of the boxplot|
|Fig4_Barplot.m                          |Fig 4: Correlation coefficients for MHW characteristics versus the anomalies of the transformed abundance for each biological variable|
|Fig5_CorrelationPlot.m                  |Fig 5: Correlations of biological variables versus MHW characteristics|
|Fig6_trophic_trophic_MHWbio_fucox_glm.m |Fig 6: Correlation plot of fucoxanthin and Zooplankton Displacement Volume Anomaly|

# Example file
Compiled data used in the study are provided as an example for future users who wish to run these scripts with up-to-date compiled datasets.    
|      File                            | Description  |
|----------------------------------------|--------------|
|table_325.csv|The co-occurrence of MHW characteristics and in situ sampling from CCE-CalCOFI Augmented Cruises in the California Current System,1983~2021 
[https://doi.org/10.6073/pasta/be6d2547424b1f9a6da933392b3c3979]|
|table_326.csv|The co-occurrence of MHW characteristics and satellite-observed Chlorophyll concentration in the California Current System,1996~2020 [https://doi.org/10.6073/pasta/537aae78a89c161ffdf3d84c50e88156]|
|OriFinal_MHW_HPLC.csv|The co-occurrence of MHW characteristics and HPLC variables. Output of Insitu_data_process/HPLC.m|
|OriFinal_MHW_ZDV.csv|The co-occurrence of MHW characteristics and ZDV. Output of Insitu_data_process/ZDV.m|
|v2_Trophic_ZooDisplace_satelliteChla.csv| The anomalies  satellite Chla in each ZDV sampling during MHWs. Output of Insitu_data_process/Trophic_Zoop_sateChla.m |
|newMHW1982-2021_sd_south.csv|The MHW occurrence in each global grid in Southern CCE region from 1982-2021.Output of Satellite_data_process/maxSDint_sateChla.m|
|Statistics_MHWbio_final.xlsx| Combined statistical test results for the following figure plotting|

# Package requirement
[gmregress](https://www.mathworks.com/matlabcentral/fileexchange/27918-gmregress) is required for Model II regression analysis.

[m_map](https://www.eoas.ubc.ca/~rich/map.html) is required for plotting Fig 1a of CCE Map

[m_mhw1.0](https://github.com/ZijieZhaoMMHW/m_mhw1.0?tab=readme-ov-file) is required for plotting Fig 1b of MHW detection through time.

[fitmethis](https://github.com/quitadal/EPINETLAB/blob/master/EPINETLAB/fitmethis.m) is required for checking the data normality while doing statistical test.

[lsqfitgm](https://gml.noaa.gov/aftp/pub/john/regression/lsqfitgm.pro) is required for plotting Fig 6.

[lat2cc](https://calcofi.org/sampling-info/station-positions/2013-line-sta-algorithm/) and [StationOrder.csv](https://calcofi.org/sampling-info/station-positions/) are recommended for converting between geographic coordinates in latitude and longitude and the line and station sampling pattern of the California Cooperative Fisheries Investigations (CalCOFI) program.
