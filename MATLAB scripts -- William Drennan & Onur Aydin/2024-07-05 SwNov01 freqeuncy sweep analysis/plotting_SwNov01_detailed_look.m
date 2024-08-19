close all
clc
clear
% write a code which returns chunks of the timeseries between timestamps
load('txyrm_v2.mat')

t = data(:,1)-8.6; %s
x = data(:,2); %um
y = data(:,3); %um
r = data(:,4); %um
muscle = data(:,5); %um
m = 27; %mg

load('tstim_v1.mat')
tstim = data(:,1); %s
vstim = data(:,2); %ON/OFF

% Overview figure
f = figure(1)
f.Units = "inches"
f.Position = [1, 0, 8.3, 9]
f.Renderer = "painters"

tstartList = 5.5:10:(5.5+110);
tstartList(1) = 4.5;
tendList = tstartList + 9.9;
tendList(1) = tendList(1) + 1

color_code = {"k","r","g","b","m","c","k","r","g","b","m","c"}
color_code = linspecer(11)*0.75
%color_code = color_code + (1-color_code)*0.5

subplot(4,11,1:11)
for i = 1:11
    ROI = (tstim > tstartList(i) & tstim < tendList(i));
    plot(tstim(ROI),vstim(ROI), "Color", color_code(i,:))
    hold on
end

xlim([0,120])
ylim([-0.1,1.1])
set(gca,'XTickLabel',[],'XTick',[0,5,15,25,35,45,55,65,75,85,95,105,115],'YTick',[0,1],'YTickLabel',["OFF","ON"])
ylabel({"Electrical","Stimulation"})
ax = gca
ax.FontSize = 12

subplot(4,11,12:22)

for i = 1:11
    ROI = (t > tstartList(i) & t < tendList(i));
    plot(t(ROI), muscle(ROI), "Color", color_code(i,:))
    hold on
end
xlim([0,120])
ylim([150,310])
set(gca,'XTickLabel',[],'XTick',[0,5,15,25,35,45,55,65,75,85,95,105,115])
ylabel({"Swimmer Grip", "Displacement ({\mu}m)"})
ax = gca
ax.FontSize = 12
set(gca,'YTick',150:50:300)

subplot(4,11,23:33);
for i = 1:11
    ROI = (t > tstartList(i) & t < tendList(i));
    plot(t(ROI), r(ROI) - min(r(ROI)), "Color", color_code(i,:))
    hold on
end
set(gca,'XTick',[0,5,15,25,35,45,55,65,75,85,95,105,115],'XTickLabel',[0,0,10,20,30,40,50,60,70,80,90,100,110])
xlim([0,120])
ylim([0,500])
xlabel("Time")
ylabel({"Projected Swimmer","Position ({\mu}m)"})
ax = gca
ax.FontSize = 12
set(gca,'YTick',0:100:500)

for i = 1:11
    subplot(4,11,[33 + i])
    ROI = (t > tstartList(i) & t < tendList(i));
    xsubset = x(ROI);
    ysubset = y(ROI);
    % p = polyfit(xsubset,ysubset,1);
    % if p(1) < 0
    %     theta = -(atan(p(1))+pi) + pi/2;
    % else 
    %     theta = -atan(p(1)) + pi/2;
    % end
    % R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    % xyprime = (R*[xsubset';ysubset'])';
    % 
    % xsubset = xyprime(:,1)
    % ysubset = xyprime(:,2)
    plot(xsubset - xsubset(1),ysubset - ysubset(1), "color", color_code(i,:))
    axis equal
    ylim([0,500])
    hold on
    quiver([0],[0],[0],[500], "k")
    set(gca,'XTick',[], 'YTick', [])
    axis off
end
%% Case 1,2,3 figure
fun1 = @(x,tdata) -x(1)*exp(-tdata/2.95)+x(3) + 1.766*tdata;
fun2 = @(x,tdata) -x(1)*exp(-tdata/2.43)+x(3) + 1.766*tdata;
fun3 = @(x,tdata) -x(1)*exp(-tdata/3.00)+x(3) + 1.766*tdata;
color_code = {"b","r","g","k","m","c","b","r","g","k","m","c"}
x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [-600,0,-1000,0]
ub = [600,100,1000,30]

figure(2); close(2); figureHandle = figure(2)
figureHandle.Position = [46.333 231.67 1616.7 577.33];

subplot(1,3,1)
xList = zeros(4,11)
RsqList = zeros(1,11)
tstartList = 11:10:(11+110);
tstartList(1) = 10;
tendList = tstartList + 4.5
freqList = [0.5, 1, 2, 3, 4, 5, 8, 10, 12, 15, 20]
for i = 1:6
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun1,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList(:,i) = x
    plot(tROI,rROI,color_code{i}, 'DisplayName', "Post " + freqList(i) + "Hz stimulation")
    hold on
    RsqList(i) = 1 - sum((rROI(a:end)-fun1(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
for i = 1:6
    x = xList(:,i)
    plot(tROI,fun1(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
end
ax = gca
ax.FontSize = 12
xlabel("Time (s)")
ylabel("Projected Swimmer Position ({\mu}m)")
legend("location", 'southoutside')
title("{\tau} = 4.5 sec")

subplot(1,3,2)
for i = 7:11
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun2,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList(:,i) = x
    plot(tROI,rROI,color_code{i}, 'DisplayName', "Post " + freqList(i) + "Hz stimulation")
    hold on
    RsqList(i) = 1 - sum((rROI(a:end)-fun2(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
for i = 7:11
    x = xList(:,i)
    plot(tROI,fun2(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
end
ax = gca
ax.FontSize = 12
xlabel("Time (s)")
ylabel("Projected Swimmer Position ({\mu}m)")
legend("location", 'southoutside')
title("{\tau} = 1.6 sec")

subplot(1,3,3)
xList2 = zeros(4,11)
RsqList2 = zeros(1,11)
tstartList = 6:10:(6+110);
tstartList(1) = 5;
tendList = tstartList + 4.5
for i = 7:11
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun3,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList2(:,i) = x
    plot(tROI,rROI,color_code{i}, 'DisplayName', freqList(i) + "Hz stimulation")
    hold on
    RsqList2(i) = 1 - sum((rROI(a:end)-fun3(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
for i = 7:11
    x = xList2(:,i)
    plot(tROI,fun3(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
end
ax = gca
ax.FontSize = 12
xlabel("Time (s)")
ylabel("Projected Swimmer Position ({\mu}m)")
legend("location", 'southoutside')
title("{\tau} = 0.98 sec")


%% Case 1,2,3 figure - With scaling
fun1 = @(x,tdata) -x(1)*exp(-tdata/2.95)+x(3) + 1.766*tdata;
fun2 = @(x,tdata) -x(1)*exp(-tdata/2.43)+x(3) + 1.766*tdata;
fun3 = @(x,tdata) -x(1)*exp(-tdata/3.00)+x(3) + 1.766*tdata;

fun1s = @(tdata)  -exp(-tdata/2.95);
fun2s = @(tdata)  +exp(-tdata/2.43);
fun3s = @(tdata)  -exp(-tdata/3.00);

color_code = {"k","r","g","b","m","c","k","r","g","b","m","c"}
x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [-600,0,-1000,0]
ub = [600,100,1000,30]

figure(2); close(2); figureHandle = figure(2)
figureHandle.Position = [46.333 231.67 1616.7 577.33];

subplot(1,3,1)
xList = zeros(4,11)
RsqList = zeros(1,11)
tstartList = 11:10:(11+110);
tstartList(1) = 10;
tendList = tstartList + 4.5
freqList = [0.5, 1, 2, 3, 4, 5, 8, 10, 12, 15, 20]
for i = 1:6
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun1,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList(:,i) = x
    plot(tROI,(rROI - 1.766*tROI - x(3))./x(1),color_code{i}, 'DisplayName', "Post " + freqList(i) + "Hz stimulation")
    hold on
    RsqList(i) = 1 - sum((rROI(a:end)-fun1(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
% for i = 1:6
%     x = xList(:,i)
%     plot(tROI,fun1(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
% end

plot(tROI,fun1s(tROI),color_code{7}, "LineStyle","--",'DisplayName', "{-e^{t / {\tau}}}, {\tau} = 2.95 s ({R^2} = " + num2str(mean(RsqList(1:6)),'%.2f') + "\pm" + num2str(std(RsqList(1:6)),'%.2f') + ")")

ax = gca
ax.FontSize = 12
xlabel("Time (s)")
ylabel("Normalized Projected Swimmer Position (-/-)")
legend("location", 'southoutside')
%title("{\tau} = 4.5 sec")

subplot(1,3,2)
for i = 7:11
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun2,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList(:,i) = x
    plot(tROI,(rROI - 1.766*tROI - x(3))./abs(x(1)),color_code{i}, 'DisplayName', "Post " + freqList(i) + "Hz stimulation")
    hold on
    RsqList(i) = 1 - sum((rROI(a:end)-fun2(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
% for i = 7:11
%     x = xList(:,i)
%     plot(tROI,fun2(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
% end
plot(tROI,fun2s(tROI),color_code{7}, "LineStyle","--",'DisplayName', "{e^{t / {\tau}}}, {\tau} = 2.43 s ({R^2} = " + num2str(mean(RsqList(7:end)),'%.2f') + "\pm" + num2str(std(RsqList(7:end)),'%.2f') + ")")


ax = gca
ax.FontSize = 12
xlabel("Time (s)")
ylabel("Normalized Projected Swimmer Position (-/-)")
legend("location", 'southoutside')
%title("{\tau} = 1.6 sec")

subplot(1,3,3)
xList2 = zeros(4,11)
RsqList2 = zeros(1,11)
tstartList = 6:10:(6+110);
tstartList(1) = 5;
tendList = tstartList + 4.5
for i = 7:11
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun3,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList2(:,i) = x
    plot(tROI,(rROI - 1.766*tROI - x(3))./abs(x(1)),color_code{i}, 'DisplayName', freqList(i) + "Hz stimulation")
    hold on
    RsqList2(i) = 1 - sum((rROI(a:end)-fun3(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
% for i = 7:11
%     x = xList2(:,i)
%     plot(tROI,fun3(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
% end

plot(tROI,fun3s(tROI),color_code{7}, "LineStyle","--",'DisplayName', "{-e^{t / {\tau}}}, {\tau} = 3.00 s ({R^2} = " + num2str(mean(RsqList2(7:end)),'%.2f') + "\pm" + num2str(std(RsqList2(7:end)),'%.2f') + ")")


ax = gca
ax.FontSize = 12
xlabel("Time (s)")
ylabel("Normalized Projected Swimmer Position (-/-)")
legend("location", 'southoutside')
%title("{\tau} = 0.98 sec")

%% Case 1,2,3 figure - With scaling
fun1 = @(x,tdata) -x(1)*exp(-tdata/2.8)+x(3) + 1.766*tdata;
fun2 = @(x,tdata) -x(1)*exp(-tdata/2.8)+x(3) + 1.766*tdata;
fun3 = @(x,tdata) -x(1)*exp(-tdata/2.8)+x(3) + 1.766*tdata;

fun1s = @(tdata)  -exp(-tdata/2.8);
fun2s = @(tdata)  +exp(-tdata/2.8);
fun3s = @(tdata)  -exp(-tdata/2.8);

color_code = {"k","r","g","b","m","c","k","r","g","b","m","c"}
x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [-600,0,-1000,0]
ub = [600,100,1000,30]

figure(2); close(2); figureHandle = figure(2)
figureHandle.Position = [46.333 231.67 1616.7 577.33];

subplot(1,3,1)
xList = zeros(4,11)
RsqList = zeros(1,11)
tstartList = 11:10:(11+110);
tstartList(1) = 10;
tendList = tstartList + 4.5
freqList = [0.5, 1, 2, 3, 4, 5, 8, 10, 12, 15, 20]
for i = 1:6
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun1,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList(:,i) = x
    plot(tROI,(rROI - 1.766*tROI - x(3))./x(1),color_code{i}, 'DisplayName', "Post " + freqList(i) + "Hz stimulation")
    hold on
    RsqList(i) = 1 - sum((rROI(a:end)-fun1(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
% for i = 1:6
%     x = xList(:,i)
%     plot(tROI,fun1(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
% end

plot(tROI,fun1s(tROI),color_code{7}, "LineStyle","--",'DisplayName', "{-Ae^{t / {\tau}} + B + v_{drift} t}, {\tau} = 2.8 s ({R^2} = " + num2str(mean(RsqList(1:6)),'%.2f') + "\pm" + num2str(std(RsqList(1:6)),'%.2f') + ")")

ax = gca
ax.FontSize = 12
xlabel("Time (s)")
ylabel({"Normalized Projected Swimmer Position (-/-)","(p(t)-B-v_{drift}t)/A"})
legend("location", 'southoutside')
%title("{\tau} = 4.5 sec")

subplot(1,3,2)
for i = 7:11
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun2,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList(:,i) = x
    plot(tROI,(rROI - 1.766*tROI - x(3))./abs(x(1)),color_code{i}, 'DisplayName', "Post " + freqList(i) + "Hz stimulation")
    hold on
    RsqList(i) = 1 - sum((rROI(a:end)-fun2(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
% for i = 7:11
%     x = xList(:,i)
%     plot(tROI,fun2(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
% end
plot(tROI,fun2s(tROI),color_code{7}, "LineStyle","--",'DisplayName', "{Ae^{t / {\tau}} + B + v_{drift} t}, {\tau} = 2.8 s ({R^2} = " + num2str(mean(RsqList(7:end)),'%.2f') + "\pm" + num2str(std(RsqList(7:end)),'%.2f') + ")")


ax = gca
ax.FontSize = 12
xlabel("Time (s)")
%ylabel({"Normalized Projected Swimmer Position (-/-)","(p(t)-B-v_{drift}t)/A"})
legend("location", 'southoutside')
%title("{\tau} = 1.6 sec")

subplot(1,3,3)
xList2 = zeros(4,11)
RsqList2 = zeros(1,11)
tstartList = 6:10:(6+110);
tstartList(1) = 5;
tendList = tstartList + 4.5
for i = 7:11
    ROI = (t > tstartList(i) & t < tendList(i))
    tROI = t(ROI)
    rROI = r(ROI)
    tROI = tROI-tROI(1)
    rROI = rROI-rROI(1)
    a = 20
    x = lsqcurvefit(fun3,x0,tROI(a:end),rROI(a:end),lb,ub,options);
    xList2(:,i) = x
    plot(tROI,(rROI - 1.766*tROI - x(3))./abs(x(1)),color_code{i}, 'DisplayName', freqList(i) + "Hz stimulation")
    hold on
    RsqList2(i) = 1 - sum((rROI(a:end)-fun3(x,tROI(a:end))).^2)/sum((rROI(a:end)-mean(rROI(a:end))).^2);
end
% for i = 7:11
%     x = xList2(:,i)
%     plot(tROI,fun3(x,tROI),color_code{i}, "LineStyle","--",'DisplayName', "Fit ({R^2} = " + num2str(RsqList(i),'%.2f') + ")")
% end

plot(tROI,fun3s(tROI),color_code{7}, "LineStyle","--",'DisplayName', "{-Ae^{t / {\tau}} + B + v_{drift} t}, {\tau} = 2.8 s ({R^2} = " + num2str(mean(RsqList2(7:end)),'%.2f') + "\pm" + num2str(std(RsqList2(7:end)),'%.3f') + ")")


ax = gca
ax.FontSize = 12
xlabel("Time (s)")
%ylabel({"Normalized Projected Swimmer Position (-/-)","(p(t)-B-v_{drift}t)/A"})
legend("location", 'southoutside')
%title("{\tau} = 0.98 sec")