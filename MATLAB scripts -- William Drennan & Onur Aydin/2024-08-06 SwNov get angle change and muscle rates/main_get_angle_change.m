clear; close all;

load('theta_change_SwNov.mat')


offsets = [0, 140, 50, 30, 0, 0]

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