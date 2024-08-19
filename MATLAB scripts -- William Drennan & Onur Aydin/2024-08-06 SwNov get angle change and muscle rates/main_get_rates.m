clear; close all;

load('theta_change_SwNov.mat')
load('grip_motion_SwNov.mat')
load('position_change_SwNov.mat')

offsets = [0, 140, 30, 15, -20, -14];

%% Get tetanus onset velocities

for_excel = zeros(5,6);
m = 6
for i = 2:7
    figure(1); plot(data3(:,i)); hold on
    keyFrameList = [1490, 1690, 1890, 2090, 2290];
    for j = 1:length(keyFrameList)
        keyFrame = keyFrameList(j) + offsets(i-1)
        ROI = keyFrame:(keyFrame + m)
        travel = data3(ROI,i);
        figure(1); plot(ROI,travel, "r"); hold on;
        p = polyfit(ROI, travel, 1)
        plot(ROI, polyval(p,ROI),"k");
        for_excel(j,i-1) = p(1)/0.05;
    end
end

%% Get tetanus release velocities

for_excel = zeros(5,6);
m = 6
for i = 2:7
    figure(1); plot(data3(:,i)); hold on
    keyFrameList = [1490, 1690, 1890, 2090, 2290] + 100;
    for j = 1:length(keyFrameList)
        keyFrame = keyFrameList(j) + offsets(i-1)
        ROI = keyFrame:(keyFrame + m)
        travel = data3(ROI,i);
        figure(1); plot(ROI,travel, "r"); hold on;
        p = polyfit(ROI, travel, 1)
        plot(ROI, polyval(p,ROI),"k");
        for_excel(j,i-1) = p(1)/0.05;
    end
end

%% Get peak muscle contraction rates

m = 7*20
for i = 2:7
    figure(1); plot(data2(:,i) + i * 100); hold on
    keyFrame = 260 + offsets(i-1)
    ROI = keyFrame:(keyFrame + m)
    muscle = data2(ROI,i);
    figure(1); plot(ROI,muscle + i * 100, "k"); hold on;
    muscleRate = diff(muscle)/0.05/1000; %mm/s
    %ub = movmax(muscleRate,40)
    figure(2); plot(ROI(2:end) + i * 400, muscleRate); hold on
    %plot(ROI(2:end) + i * 400, ub)
end

%% Get peak muscle contraction rates

m = 7*20
for i = 2:7
    figure(1); plot(data2(:,i) + i * 100); hold on
    keyFrame = 260 + offsets(i-1)
    ROI = keyFrame:(keyFrame + m)
    theta = data(ROI,i);
    figure(1); plot(ROI,theta + i * 100, "k"); hold on;
    thetaRate = diff(theta)/0.05; %mm/s
    %ub = movmax(muscleRate,40)
    figure(2); plot(ROI(2:end) + i * 400, thetaRate); hold on
    %plot(ROI(2:end) + i * 400, ub)
end

%% get all angle changes


for_excel = zeros(11,6);

for i = 2:7
    keyFrames = [300, 530, 730, 930, 1130, 1330, 1530, 1730, 1930, 2130, 2330]
    m = length(keyFrames);
    keyFrames = keyFrames + offsets(i-1);
    theta = data(:,i);
    ub = movmax(theta,40);
    lb = movmin(theta,20);
    figure(1); hold off;
    plot(ub); hold on;
    plot(theta);
    plot(lb);
    figure(2); hold off;
    change = ub-lb
    plot(change); hold on;

    changeList = zeros(m,1);
    for j = 1:m
        changeList(j) = mean(change(keyFrames(j)-20:keyFrames(j)+20));
    end
    stem(keyFrames, changeList);
    for_excel(:,i-1) = changeList;
end