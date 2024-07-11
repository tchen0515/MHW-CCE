# MHW-CCE
The files contains the codes used in Chen et al: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem
These codes can mainly be catgorized into four folders: statistical analyses, figure plotting, data pre-processing, and anomalies calculation. The first two folders are for main analysis while the latter two folders are for data quality control.  

# Instruction
The instruction is elaborated in Main_MHWbio.mlx. This live stript can also be directly used for running the codes. Please check the directory of inputs or outputs indicated in each code.
The compiled data used in the analysis are provided here (MHW-in situ data.xlsx/MHW-satelliteChla.xlsx/Statistics_MHW_final.xlsx). The raw data sources are from CCE-LTER website (indicated in the manuscript).

# Package requirement
m_mhw1.0 and fitmethis are recommended for analysis
m_map is recommended for generating figures
R package "bestNormalize" are needed for Yeo-Johnson power transformation

# data source
Compiled data (MHW in situ data.xlsx and MHW satellite Chla.xlsx) used in the analysis are available on CCE LTER DataZoo data repository and Environmental Data Initiative (EDI) repository (https://oceaninformatics.ucsd.edu/datazoo/catalogs/ccelter/datasets/319 and https://doi.org/10.6073/pasta/537aae78a89c161ffdf3d84c50e88156).

# Reference
Zhao, Z., & Marin, M. (2019). A MATLAB toolbox to detect and analyze marine heatwaves. Journal of Open Source Software, 4(33), 1124.
de Castro, F. (2024). fitmethis (https://www.mathworks.com/matlabcentral/fileexchange/40167-fitmethis)
