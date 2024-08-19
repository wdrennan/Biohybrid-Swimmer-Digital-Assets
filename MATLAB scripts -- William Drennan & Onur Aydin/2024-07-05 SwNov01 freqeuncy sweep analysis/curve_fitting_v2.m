%% Curve fitting with variable tau

clear; close all;
load('post_stimulation_drift_v2.mat')
tdata = data(:,1);

close all
format short g

m = 27; %mg

a = 10

fun = @(x,tdata) -x(1)*exp(-tdata/x(2))+x(3) + 1.766*tdata;

x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [-600,0,-1000,0]
ub = [600,100,1000,2]

res = zeros(4,11)

color_code = {"b","r","g","k","m","c","b","r","g","k","m","c"}

for i = 2:12
    freqdata = data(:,i);
    %freqdata = freqdata - freqdata(1)
    x = lsqcurvefit(fun,x0,tdata(a:end),freqdata(a:end),lb,ub,options);
    res(:,i-1) = x
    if i <= 7 
        figure(1)
        plot(tdata,freqdata,color_code{i-1})
        hold on
        plot(tdata,fun(x,tdata),color_code{i-1}, "LineStyle","--")
    else
        figure(2)
        plot(tdata,freqdata,color_code{i-1})
        hold on
        plot(tdata,fun(x,tdata),color_code{i-1}, "LineStyle","--")
    end
end


v0 = res(1,:)./res(2,:)

gamma = 1./res(2,:) * m

%legend(["0.5 Hz","fit","1 Hz","fit","2 Hz","fit","3 Hz","fit","4 Hz","fit","5 Hz","fit"], "Location","eastoutside")
for i = 1:2
    figure(i)
    xlabel("Time (s)")
    ylabel("Projected Swimmer Position ({\mu}m)")
end

ax = gca
ax.FontSize = 18

res

load('tetanus_onset_drift.mat')
tdata = data(:,1);

fun = @(x,tdata) -x(1)*exp(-tdata/x(2))+x(3) +  1.766*tdata;

x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [-600,0,-1000,0]
ub = [600,100,1000,2]

res2 = zeros(4,5)

color_code = {"b","r","g","k","m","c","b","r","g","k","m","c"}

for i = 2:6
    freqdata = data(:,i);
    %freqdata = freqdata - freqdata(1)
    x = lsqcurvefit(fun,x0,tdata(a:end),freqdata(a:end),lb,ub,options);
    res2(:,i-1) = x
    figure(3)
    plot(tdata,freqdata,color_code{i-1})
    hold on
    plot(tdata,fun(x,tdata),color_code{i-1}, "LineStyle","--")
end


v0 = res2(1,:)./res2(2,:)

gamma = 1./res2(2,:) * m

%legend(["0.5 Hz","fit","1 Hz","fit","2 Hz","fit","3 Hz","fit","4 Hz","fit","5 Hz","fit"], "Location","eastoutside")
for i = 3
    figure(i)
    xlabel("Time (s)")
    ylabel("Projected Swimmer Position ({\mu}m)")
end

ax = gca
ax.FontSize = 18

res2

tau1 = mean(res(2,1:7))
tau2 = mean(res(2,8:end))
tau3 = mean(res2(2,:))

all_tau = [res(2,:), res2(2,:)]

%% Curve fitting with fixed tau

close all;
load('post_stimulation_drift_v2.mat')
tdata = data(:,1);

close all
format short g

m = 27; %mg

fun1a = @(x,tdata) -x(1)*exp(-tdata/tau1)+x(3) + 1.766*tdata;
fun1b = @(x,tdata) -x(1)*exp(-tdata/tau2)+x(3) + 1.766*tdata;

x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [-600,0,-1000,0]
ub = [600,100,1000,10]

res = zeros(4,11)

residualList = zeros(11,1)

color_code = {"b","r","g","k","m","c","b","r","g","k","m","c"}

for i = 2:12
    freqdata = data(:,i);
    %freqdata = freqdata - freqdata(1)
    
    if i <= 7 
        x = lsqcurvefit(fun1a,x0,tdata(a:end),freqdata(a:end),lb,ub,options);
        res(:,i-1) = x
        figure(1)
        plot(tdata,freqdata,color_code{i-1})
        hold on
        plot(tdata,fun1a(x,tdata),color_code{i-1}, "LineStyle","--")
        residualList(i-1) = 1 - sum((freqdata(a:end)-fun1a(x,tdata(a:end))).^2)/sum((freqdata(a:end)-mean(freqdata(a:end))).^2);
    else
        x = lsqcurvefit(fun1b,x0,tdata(a:end),freqdata(a:end),lb,ub,options);
        res(:,i-1) = x
        
        figure(2)
        plot(tdata,freqdata,color_code{i-1})
        hold on
        plot(tdata,fun1b(x,tdata),color_code{i-1}, "LineStyle","--")
        residualList(i-1) = 1 - sum((freqdata(a:end)-fun1b(x,tdata(a:end))).^2)/sum((freqdata(a:end)-mean(freqdata(a:end))).^2);
    end
end


v0 = res(1,:)./res(2,:)

gamma = 1./res(2,:) * m

%legend(["0.5 Hz","fit","1 Hz","fit","2 Hz","fit","3 Hz","fit","4 Hz","fit","5 Hz","fit"], "Location","eastoutside")
for i = 1:2
    figure(i)
    xlabel("Time (s)")
    ylabel("Projected Swimmer Position ({\mu}m)")
end

ax = gca
ax.FontSize = 18

res

load('tetanus_onset_drift.mat')
tdata = data(:,1);

m = 27; %mg
%fun = @(x,tdata) x(1)*m/x(2)*log(1+x(2)/m*tdata) + x(3);

fun = @(x,tdata) -x(1)*exp(-tdata/tau3)+x(3) + 1.766*tdata;

x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [-600,0,-1000,0]
ub = [600,100,1000,30]

res2 = zeros(4,5)

color_code = {"b","r","g","k","m","c","b","r","g","k","m","c"}

for i = 2:6
    freqdata = data(:,i);
    %freqdata = freqdata - freqdata(1)
    x = lsqcurvefit(fun,x0,tdata(a:end),freqdata(a:end),lb,ub,options);
    res2(:,i-1) = x
    figure(3)
    plot(tdata,freqdata,color_code{i-1})
    hold on
    plot(tdata,fun(x,tdata),color_code{i-1}, "LineStyle","--")
end


v0 = res2(1,:)./res2(2,:)

gamma = 1./res2(2,:) * m

%legend(["0.5 Hz","fit","1 Hz","fit","2 Hz","fit","3 Hz","fit","4 Hz","fit","5 Hz","fit"], "Location","eastoutside")
for i = 3
    figure(i)
    xlabel("Time (s)")
    ylabel("Projected Swimmer Position ({\mu}m)")
end

ax = gca
ax.FontSize = 18