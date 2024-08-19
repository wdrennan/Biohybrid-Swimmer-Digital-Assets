% clear; close all;
% 
% load('theta_v_force.mat')
close all
p = polyfit(data(:,1), data(:,2),2);

phi = min(data(:,1)):0.1:max(data(:,1));
plot(phi, polyval(p,phi))
hold on
plot(data(:,1), data(:,2),".")

p