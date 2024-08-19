clear; close all;
load('single_muscle_twitch.mat')

t = data(:,1)-min(data(:,1)); t = t*2;
y = data(:,2); y = y - min(y); y = y/max(y);


f = @(tq) interp1(t,y,tq,'linear',0);

tq = 0:0.001:2;
n = 3
freq = [1,8,15]
for j = 1:n
    subplot(1,n,j)
    tp = 0.2:1/freq(j):2;
    g = zeros(size(tq));
    h = zeros(size(tq));
    for i = 1:length(tp)
        g = g + f(tq-tp(i)); 
        h(tq >= tp(i) & tq < tp(i) + 0.025) = 0.2;
        plot(tq,f(tq-tp(i)),"b"); hold on
    end
    
    plot(tq,g, "k"); hold on;
    plot(tq,h,"r")
    xlim([0,2])
    ylim([-0.1,2.5])
    xlabel("time")
    ylabel("contraction")
    axis off
end

k = gcf
k.Renderer = "painters"