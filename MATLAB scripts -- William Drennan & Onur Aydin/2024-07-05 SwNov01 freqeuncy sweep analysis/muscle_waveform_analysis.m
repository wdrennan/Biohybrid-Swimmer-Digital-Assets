clear; close all;
load('SwNov01_muscle_waveform_v2.mat')

figure(1)
plot(data(:,1),data(:,2))
hold on
plot(data(:,1),data(:,3))