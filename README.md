# MHW-CCE
The files contains the codes used in Chen et al: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem
These codes can mainly be catgorized into three parts, storaged as three branches on this repository: 1) Satellite data processing ,2) _In situ_ data processing and 3) Main analyses. Each branches have their own readme file to explain the propose of the codes and elborate the procedure of running the codes. The links of raw data source and the required packages/functions are also indicated in the code comments in each codes.   
Please note that some samplings are ongoing projects (e.g. ZooScan), so new raw data from each website may be updated periodically.

# Package /funcation requirement
[m_mhw1.0](https://github.com/ZijieZhaoMMHW/m_mhw1.0?tab=readme-ov-file) and [fitmethis](https://github.com/quitadal/EPINETLAB/blob/master/EPINETLAB/fitmethis.m) are recommended for analysis

[m_map](https://www.eoas.ubc.ca/~rich/map.html) is recommended for generating figures

Function _month2season_ is applied to insert season inofmration before calculating seasonal scale anomalies

R package "tidyverse" and "bestNormalize" are needed for Yeo-Johnson power transformation

# Example
|Code|Description|
|------|------|
|MHW-in situ data.xlsx| The co-occurrence of MHW characteristics and *in situ* sampling from CCE-CalCOFI Augmented Cruises in the California Current System [table_325.csv](https://doi.org/10.6073/pasta/be6d2547424b1f9a6da933392b3c3979)|
|MHW-satellite data.xlsx|The co-occurrence of MHW characteristics and satellite-observed Chlorophyll concentration in the California Current System [table_326.csv](https://doi.org/10.6073/pasta/537aae78a89c161ffdf3d84c50e88156)|
|Statistics_MHWbio_final.xlsx|those results were then manually binned into a main table for the figure plotting.
