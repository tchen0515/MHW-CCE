# MHW-CCE
The files contains the codes used in Chen et al: Multi-trophic level responses to marine heatwave disturbances in the California Current Ecosystem
These codes can mainly be catgorized into four parts: data pre-processing, anomalies calculation, statistical analyses and figure generating. 
The process of the analysis is elaborated in Main_MHWbio.mlx 

# Data source
Satellite sea surface temperature (https://podaac.jpl.nasa.gov/dataset/AVHRR_OI-NCEI-L4-GLOB-v2.0)
Satellite chlorophyll a concentration (https://spg-satdata.ucsd.edu/CC4km/)
Net primary production, vertically integrated chlorophyll, zooplankton displacement volume, fish eggs, and fish larvae (https://calcofi.org/)
Zooplankton taxon-specific biomass by ZooScan (https://oceaninformatics.ucsd.edu/zooscandb/secure/login.php)
Size-fractionated chlorophyll, HPLC, flow cytometry (https://oceaninformatics.ucsd.edu/datazoo/catalogs/ccelter/datasets).

# Requirement
m_mhw1.0 and fitmethis are recommended for analysis
m_map is recommended for generating figures

# Reference
Zhao, Z., & Marin, M. (2019). A MATLAB toolbox to detect and analyze marine heatwaves. Journal of Open Source Software, 4(33), 1124.
de Castro, F. (2024). fitmethis (https://www.mathworks.com/matlabcentral/fileexchange/40167-fitmethis)
