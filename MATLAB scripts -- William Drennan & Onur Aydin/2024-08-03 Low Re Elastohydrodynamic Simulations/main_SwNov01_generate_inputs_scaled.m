%% main_SwNov01_generate_inputs_scaled
clear
close all

load('SwNov01_x3_grip_waveform.mat')
t = data(:,1);
x3 = data(:,2);

p_x2_of_x3 = [0.000618258,0.83063297,-1.783892396];
p_theta_of_x3 = [-0.00021897,0.165247374,-0.970497407];

tonic_x3 = 163.4 % um

a  = 12.4
tstartList = a:10:(a+110);
tstartList(1) = a-1;
tendList = tstartList + 7;
%tendList(1) = tendList(1) + 1

color_code = {"k","r","g","b","m","c","k","r","g","b","m","c"}

inputTable = []

figure(1)
for i = 1:6
    ROI = (t > tstartList(i) & t < tendList(i));
    %plot(t(ROI), x3(ROI), "Color", color_code{i})
    hold on
    inputTable(:,i) = (x3(ROI)-min(x3(ROI)))/max(x3(ROI)-min(x3(ROI)));
    plot(t(ROI), inputTable(:,i), "Color", color_code{i})
end
