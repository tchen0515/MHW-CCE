%%% classify month into season
function [s]=month2season(x)

if x>=3 && x<=5  % spring
    s=1;         
elseif x>=6 && x<=8  %summer
    s=2;          
elseif x>=9 && x<=11  %autumn
    s=3;           
else x==12||x==1||x==2  %winter
    s=4;           
end
end