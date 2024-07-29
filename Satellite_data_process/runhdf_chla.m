% convert raw Satellite Chla data (.hdf) to (.mat) in using loop 
close all
clear all

code='MHW-CCE/1-Satellite_data_processing' % directory where the function hdfchla.m is storaged  
for i =1996:2020 %hdf file classified by years. Change the years if you sue up-to-date data
    hdfchla(i);
    cd(code)
end

