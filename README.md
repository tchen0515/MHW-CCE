# MHW-CCE
The files contains the codes used in Chen et al: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem
These codes can mainly be catgorized into three parts, storaged as three branches on this repository:
1) Satellite data processing
2) _In situ_ data processing
3) Main analyses

Plase follow the order of the branched to run the scripts. Each branches have their own README file to explaining the purpose of each script and the sequence in which they should be run. The links of raw data source, required packages, functions, and outputs from other scripts in this repository are indicated in the code comments and README files to to help users understand the dependencies and execution order.
Please note that some samplings are ongoing projects (e.g. ZooScan), so new raw data from each website may be updated periodically.

# Package /function requirement
[m_mhw1.0](https://github.com/ZijieZhaoMMHW/m_mhw1.0?tab=readme-ov-file) and [fitmethis](https://github.com/quitadal/EPINETLAB/blob/master/EPINETLAB/fitmethis.m) are recommended for analysis

[m_map](https://www.eoas.ubc.ca/~rich/map.html) is recommended for generating figures


R package "tidyverse" and "bestNormalize" are needed for Yeo-Johnson power transformation

# Example
|Code|Description|
|------|------|
|MHW-in situ data.xlsx| [The co-occurrence of MHW characteristics and *in situ* sampling from CCE-CalCOFI Augmented Cruises in the California Current System](https://doi.org/10.6073/pasta/be6d2547424b1f9a6da933392b3c3979)|
|MHW-satellite data.xlsx|[The co-occurrence of MHW characteristics and satellite-observed Chlorophyll concentration in the California Current System](https://doi.org/10.6073/pasta/537aae78a89c161ffdf3d84c50e88156)|
|Statistics_MHWbio_final.xlsx|Main table containg the statisitcal results of the correlation of MHW characterisitcs and each variable for the figure plotting.
