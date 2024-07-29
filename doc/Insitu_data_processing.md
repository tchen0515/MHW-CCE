# 2.	The anomalies of _in situ_ sampling variables during MHWs
  These scripts detect anomalies during MHWs for each _in situ_ sampling variable. The final outputs of these scripts are used to generate the compiled data for the main analyses (e.g., table_325.csv). During the power transformation process, the datasets of microbial variables and ZDV are log-10 transformed, while the Nitracline, Fish egg & larvae, and ZooScan datasets undergo Yeo-Johnson transformation in R. Therefore, both MATLAB and R scripts will be used interactively for those datasets, and the order for running the codes is indicated below.
## log-10 transformation
|Code|Dataset|
|------|-----|
|HPLC.m|Phytoplankton taxon-specfic pigment analysis|
|IntChla.m|Vertically-integrated Chlorophyll|
|IntPP.m|Vertically-integrated Primary Production|
|PicoBacteria.m|Picoplankton and Heterotrophic Bacteria Flow cytometry analysis|
|SizeFraction.m|Size Fractionated Chlorophyll|
|ZDV.m|Zooplankton Displacement Volume|
## Yeo-Johnson transformation
### ZooScan
For ZooScan taxon-specific abundance, we first used R to clean up the raw data and then conducted the rest of the processing in MATLAB.
Usage order|Code|
|------|------|
|1|ZooScan_YJtrans.R|
|2|ZooScan_afterYJ.m|

For Nitracline dpeth, Fish egg & larvae data, we first used MATLAB to clean up data, and then switched to R for conducting Yeo-Johnson transformations, and back to MATLAB to conduct the rest of the processing.
### Nitracline
|Usage order|Code|
|------|------|
|1|Nitracline_beforeYJ.m|
|2|Nitraclin _YJtrans.R|
|3|Nitracline_afterYJ.m|
### Fish egg
|Usage order|Code|
|------|------|
|1|FishEgg_beforeYJ.m|
|2|FishEgg_YJtrans.R|
|3|FishEgg_afterYJ.m|
### Fish larvae
|Usage order|Code|
|------|------|
|1|FishLarvae_beforeYJ.m|
|2|FishLarvae_YJtrans.R|
|3|FishLarvae_afterYJ.m|

In our study, we also investigated how MHW impacts on plankton trophic relationship by calculating the correlation of ZDV and four potential prey variables (Satellite Chla, Vertically-integrated Chla, Chla >20 um and Fucoxanthin) during MHWs. Due to the inconsistent temporal scale between satellite Chla and _in situ_ sampling data, the co-occurrence of ZDV and satellite Chla during MHWs needs to be detected before investigating the impact of MHWs on plankton trophic relationships.
|Code|Description|
|------|-----|
|Trophic_Zoop_sateChla.m|detect the co-occurrence of ZDV sampling and satellite Chla sampling during MHWs|

# Package/Function requirement

[fitmethis](https://github.com/quitadal/EPINETLAB/blob/master/EPINETLAB/fitmethis.m) is required for checking the data normality while doing statistical test.

Function _month2season_ (provided here) is applied to insert season information before calculating seasonal scale anomalies

R package "tidyverse" and "bestNormalize" are needed for Yeo-Johnson power transformation.

[StationOrder.csv](https://calcofi.org/sampling-info/station-positions/) is recommended for converting between geographic coordinates in latitude and longitude and the line and station sampling pattern of the California Cooperative Fisheries Investigations (CalCOFI) program.

Output from [m_mhw1.0](https://github.com/ZijieZhaoMMHW/m_mhw1.0?tab=readme-ov-file) and sd_SSTanomaly.m (MHW-CCE/Satellite_data_processing) are required for algining the mWH occurrence with biological sampling and assigning corresponding standardized MHW intensity.

# Data source
Net primary production, vertically integrated chlorophyll (https://calcofi.org/data/oceanographic-data/bottle-database/)

Size-fractionated chlorophyll (https://doi.org/10.6073/pasta/8ebed2a2ac22a27b23e7ba98f10dcbb4), HPLC (https://doi.org/10.6073/pasta/831e099fb086954d3d73638d33d3dd05)

Flow cytometry of picoplankton and heterotrophic bacteria (https://doi.org/10.6073/pasta/994126a7ba3d90250cf371d92b134538)

Zooplankton displacement volume (https://calcofi.org/data/marine-ecosystem-data/zooplankton/)

Zooplankton taxon-specific abundansce by ZooScan (https://oceaninformatics.ucsd.edu/zooscandb/)

Fish eggs (https://coastwatch.pfeg.noaa.gov/erddap/tabledap/erdCalCOFIcufes.html) and fish larvae (https://coastwatch.pfeg.noaa.gov/erddap/search/index.html?page=1&itemsPerPage=1000&searchFor=calcofi)
