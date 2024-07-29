# MHW-CCE
The files contain the codes used in Chen _et al._: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem. These codes can mainly be categorized into three parts, stored as three branches in this repository:

1) Satellite data processing

2) _In situ_ data processing

3) Main analyses

Please follow the order of the branches to run the scripts. Each branch has its own README file explaining the purpose of each script and the sequence in which they should be run. The links to raw data sources, required packages, functions, and outputs from other scripts in this repository are indicated in the code comments and README files to help users understand the dependencies and execution order. Please note that some samples are ongoing projects (e.g., ZooScan), so new raw data from each website may be updated periodically.

# Package /function requirement
[m_mhw1.0](https://github.com/ZijieZhaoMMHW/m_mhw1.0?tab=readme-ov-file) and [fitmethis](https://github.com/quitadal/EPINETLAB/blob/master/EPINETLAB/fitmethis.m) are recommended for analysis

[m_map](https://www.eoas.ubc.ca/~rich/map.html) is recommended for generating figures

R package "tidyverse" and "bestNormalize" are needed for Yeo-Johnson power transformation

