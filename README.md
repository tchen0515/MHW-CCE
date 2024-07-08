# MHW-CCE
The files contains the codes used in Chen et al: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem
These codes can mainly be catgorized into four folders: statistical analyses, figure plotting, data pre-processing, and anomalies calculation. The first two folders are for main analysis while the latter two folders are for data quality control.  

# Instruction
The instruction is elaborated in Main_MHWbio.mlx. This live stript can also be directly used for running the codes.
The compiled data used in the analysis are provided here (MHW-in situ data.xlsx/MHW-satelliteChla.xlsx/Statistics_MHW_final.xlsx). The raw data sources are from CCE-LTER website (indicated in the manuscript).

# Package requirement
m_mhw1.0 and fitmethis are recommended for analysis
m_map is recommended for generating figures
R package "bestNormalize" are needed for Yeo-Johnson power transformation

# Reference
Zhao, Z., & Marin, M. (2019). A MATLAB toolbox to detect and analyze marine heatwaves. Journal of Open Source Software, 4(33), 1124.
de Castro, F. (2024). fitmethis (https://www.mathworks.com/matlabcentral/fileexchange/40167-fitmethis)
