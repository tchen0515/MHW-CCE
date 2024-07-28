# MHW-CCE
The files contains the codes used in Chen et al: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem
These codes can mainly be catgorized into three branches: 1) Satellite data processing ,2) _In situ_ data processing and 3) Main analyses. Each branches have their own readme file to explain the propose of each codes and elborate the order of running the codes. The links of raw data source and the required packages/functions are also indicated in the code comments in each codes.   
Please note that some samplings are ongoing projects (e.g. ZooScan), so new raw data from each website may be updated periodically.

# Example data 


# Package requirement
m_mhw1.0 and fitmethis are recommended for analysis
m_map is recommended for generating figures
R package "bestNormalize" are needed for Yeo-Johnson power transformation

# Data source
Compiled data (MHW-in situ data.xlsx and MHW-satellite Chla.xlsx) used in the analysis are available on CCE LTER DataZoo data repository and Environmental Data Initiative (EDI) repository (https://doi.org/10.6073/pasta/be6d2547424b1f9a6da933392b3c3979 and https://doi.org/10.6073/pasta/537aae78a89c161ffdf3d84c50e88156).

# Reference
Zhao, Z., & Marin, M. (2019). A MATLAB toolbox to detect and analyze marine heatwaves. Journal of Open Source Software, 4(33), 1124.
de Castro, F. (2024). fitmethis (https://www.mathworks.com/matlabcentral/fileexchange/40167-fitmethis)
