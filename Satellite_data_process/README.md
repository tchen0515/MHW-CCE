# 1. MHW detection and the anomalies of satellite Chla during MHWs
These scripts detect the occurrence of Marine Heatwaves (MHWs), calculate MHW characteristics, and assess anomalies in surface chlorophyll-a (Chla). The outputs of these scripts will be used in further analysis to detect the co-occurrence of MHWs and biological anomalies.

## 1.1	SST & MHW detection
Downloading SST from [NASA](https://podaac.jpl.nasa.gov/dataset/AVHRR_OI-NCEI-L4-GLOB-v2.0) is achieved by Linux:
```
python3 pocloud_l3_subsetter.py -c CMC0.1deg-CMC-L4-GLOB-v2.0 -sd 1982-01-01T12:00:00Z -ed 2020-12-31T12:00:00Z -b="-140,25, -114,45" -d /Folder/SST --verbose
 -sd and -ed are the start dates and end dates of the dataset, while -b is the boundaries of the study region. -d is the directory the data is put in.
```
To detect the occurrence of Marine Heatwaves (MHWs), we used the package **m_mhw1.0** (see detailed instructions on the **m_mhw1.0** GitHub page). After running this package, several outputs are extensively used for further analysis of statistical tests or figure plotting. 

Additionally, Using the outputs from m_mhw1.0, we calculate the standardized SST anomaly, which represents MHW intensity in this study:

| Code     |Description|
|----------|--------|
|sd_SSTanomaly.m| Caculate standardized SST anomaly|

The output *mhw_stdanomaly_240409.mat* is used in the further analysis detect the corresponding MHW intensity for each sampling (see Section The anomalies of _in situ_ sampling variables during MHWs). 
## 1.2	Satellite-observed Chla
[Satellite-derived 4-km Chla dataset](https://spg-satdata.ucsd.edu/CC4km/) were log-10 transformed and merged into the daily scale time-series dataset. and calculate the log-10 scale satellite Chla anomalies in each grid:

|Usage order| Code or File    |Description|
|-------|----------|--------|
|1|runhdf_chla.m| Covert original file (.hdf) into .mat using function _hdfchla.m_ (provided in this branch) |
|2|bind_chla.m| Bind the seperate daily Chla file into time-series dataset|
|3|log10_chla.m|Eliminate invalid vaules and log-10 transformed the dataset|
|4|anomaly_satelliteChla .m|Calculate the anomaly of log-10 transformed satellite Chla. Due to the large stroage size of Chla dataset, the execution can take up to ~1 day)|
|5|stationCoordinate_satelliteChla.m|Find the most negative Chla anomaly for every grid in each MHW event|
|6|maxSDint_sateChla.m|Coordinate the most negative Chla anomaly and maximum standardized MHW intensity in every MHW event|

### Package requirement
[m_mhw1.0](https://github.com/ZijieZhaoMMHW/m_mhw1.0?tab=readme-ov-file) are required for detecting the MHW occurrence.

### Data source
Satellite sea surface temperature: https://podaac.jpl.nasa.gov/dataset/AVHRR_OI-NCEI-L4-GLOB-v2.0

Satellite chlorophyll a concentration: https://spg-satdata.ucsd.edu/CC4km/ 


### Reference
Zhao, Z., & Marin, M. (2019). A MATLAB toolbox to detect and analyze marine heatwaves. Journal of Open Source Software, 4(33), 1124.
