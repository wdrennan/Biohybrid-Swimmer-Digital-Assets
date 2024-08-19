clear; close all;
load('post_stimulation_drift.mat')
tdata = data(:,1);

close all
format short g

m = 27; %mg
%fun = @(x,tdata) x(1)*m/x(2)*log(1+x(2)/m*tdata) + x(3);

fun = @(x,tdata) -x(1)*exp(-tdata/x(2))+x(3) +x(4)*tdata;

x0 = [6,3,0,1];
options = optimoptions("lsqcurvefit","MaxFunctionEvaluations",1000)
lb = [0,0,-1000,0]
ub = [600,100,1000,3]

res = zeros(4,7)

color_code = {"b","r","g","k","m","c"}

for i = 2:7
    freqdata = data(:,i);
    freqdata = freqdata - freqdata(1)
    if i == 8
        freqdata = freqdata - tdata.*2;
    end
    a = 10
    x = lsqcurvefit(fun,x0,tdata(a:end),freqdata(a:end),lb,ub,options);
    res(:,i-1) = x
    figure(1)
    plot(tdata,freqdata,color_code{i-1})
    hold on
    plot(tdata,fun(x,tdata),color_code{i-1}, "LineStyle","--")
end


v0 = res(1,:)./res(2,:)

gamma = 1./res(2,:) * m

legend(["0.5 Hz","fit","1 Hz","fit","2 Hz","fit","3 Hz","fit","4 Hz","fit","5 Hz","fit"], "Location","eastoutside")
xlabel("Time (s)")
ylabel("Projected Swimmer Position ({\mu}m)")

ax = gca
ax.FontSize = 18

res