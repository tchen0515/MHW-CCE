# MHW-CCE
This repository contain the codes used in Chen _et al._: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem. The scripts are organized into three main categories, each stored in separate folders within this repository:

1) Satellite data process

2) _In situ_ data process

3) Main analyses

The scripts in data processing folders (**insitu_data_process** and **Satellite_data_process**) are designed to compile the most recent versions of the satellite and _in situ_ datasets using the latest raw data. When using up-to-date raw data, some scripts may require initial parameter declarations for the dataset period. The scripts in main analysis folder (**Main_analysis**) are written primarily to reproduce the datasets and figures included in the present study using the datasets as they existed at the time of publishing, which we have uploaded to the EDI repository or here as example files and will not be updated. In addition, the outputs from the script in data process folders that were used in main analysis are provided here as example files (MHW-CCE/Main_analysis/file/).
Each folder contains a README file explaining the purpose of each script, the sequence in which they should be run, and the required packages or functions. Links to raw data sources, required packages, functions, and outputs from other scripts are included in the code comments to assist users with understanding dependencies and execution order.

# Package/Function requirement
[m_mhw1.0](https://github.com/ZijieZhaoMMHW/m_mhw1.0?tab=readme-ov-file)

[fitmethis](https://github.com/quitadal/EPINETLAB/blob/master/EPINETLAB/fitmethis.m) 

Function _month2season_ (provided in Insitu_data_process) 

R package "tidyverse" and "bestNormalize"

[gmregress](https://www.mathworks.com/matlabcentral/fileexchange/27918-gmregress) 

[m_map](https://www.eoas.ubc.ca/~rich/map.html) 

[lsqfitgm](https://gml.noaa.gov/aftp/pub/john/regression/lsqfitgm.pro)

[lat2cc](https://calcofi.org/sampling-info/station-positions/2013-line-sta-algorithm/) and [StationOrder.csv](https://calcofi.org/sampling-info/station-positions/) 

# Data source
Satellite sea surface temperature: https://podaac.jpl.nasa.gov/dataset/AVHRR_OI-NCEI-L4-GLOB-v2.0

Satellite chlorophyll a concentration: https://spg-satdata.ucsd.edu/CC4km/

Net primary production, vertically integrated chlorophyll (https://calcofi.org/data/oceanographic-data/bottle-database/)

Size-fractionated chlorophyll (https://doi.org/10.6073/pasta/8ebed2a2ac22a27b23e7ba98f10dcbb4), HPLC (https://doi.org/10.6073/pasta/831e099fb086954d3d73638d33d3dd05)

Flow cytometry of picoplankton and heterotrophic bacteria (https://doi.org/10.6073/pasta/994126a7ba3d90250cf371d92b134538)

Zooplankton displacement volume (https://calcofi.org/data/marine-ecosystem-data/zooplankton/)

Zooplankton taxon-specific abundansce by ZooScan (https://oceaninformatics.ucsd.edu/zooscandb/)

Fish eggs (https://coastwatch.pfeg.noaa.gov/erddap/tabledap/erdCalCOFIcufes.html) and fish larvae (https://coastwatch.pfeg.noaa.gov/erddap/search/index.html?page=1&itemsPerPage=1000&searchFor=calcofi)
