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

