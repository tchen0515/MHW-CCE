%%% Log-10 transform the satellite Chla time-series dataset
close all
clear all
%import data
cd ('...')
load("chla_full_mid.mat") % output from bind_chla.m

%% eliminate invalid Chla values
% Chla:0.01<<64
chla_full_new=chla_full;
for t= 1:length(chla_full)
    for i =1:height(chla_full)
        for j=1:width(chla_full)
            if chla_full(i,j,t)<=0.01||chla_full(i,j,t)>64
                chla_full_new(i,j,t)= nan;
            end
            disp([i j t]) % display on command window as loading bar
        end
    end
end

% log-10 transfomration
chla_log10=chla_full_new;
for t= 1:length(chla_full_new)
    for i =1:height(chla_full_new)
        for j=1:width(chla_full_new)
            if isnan(chla_full_new(i,j,t))==0 &&chla_full_new(i,j,t)>0
                chla_log10(i,j,t)= log10(chla_full_new(i,j,t));
            end
            disp([i j t]) % display on command window as loading bar
        end
    end
end

%save file
cd('...')
save chla_log10_workspace.mat chla_log10 -v7.3
