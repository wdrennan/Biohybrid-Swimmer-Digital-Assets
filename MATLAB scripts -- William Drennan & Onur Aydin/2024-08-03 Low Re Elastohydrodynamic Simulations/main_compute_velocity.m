clear; close all; load('travel_simulated_v2.mat')

t = data(:,1);
highdrag = data(:,2);
lowdrag = data(:,3);
exp = data(:,4);

travel = data(:,2:4);

velocityTable = zeros(11,3);

a  = 14
tstartList = a:10:(a+110);
tstartList(1) = a-1;
tendList = tstartList + 5.5;
%tendList(1) = tendList(1) + 1

color_code = {"r","g","b","m","c","r","g","b","m","c","r"}

for j = 1:3
    figure(j)
    for i = 1:11
        if i <= 2
            ROI = (t > tstartList(i) & t < tendList(i));
            timeSub = t(ROI);
            travelSub = travel(ROI,j);
            plot(timeSub,travelSub, color = color_code{i})
            hold on
            plot(timeSub,movmin(travelSub,10), color = "r")
            p = polyfit(timeSub,movmin(travelSub,10),1);
        elseif i <= 6
            ROI = (t > tendList(i)-4 & t < tendList(i));
            timeSub = t(ROI);
            travelSub = travel(ROI,j);
            plot(timeSub,travelSub, color = color_code{i})
            hold on
            p = polyfit(timeSub,travelSub,1);
            plot(timeSub,movmin(travelSub,10), color = "r")
            p = polyfit(timeSub,movmin(travelSub,10),1);
        else
            ROI = (t > tendList(i)-2 & t < tendList(i));
            timeSub = t(ROI);
            travelSub = travel(ROI,j);
            plot(timeSub,travelSub, color = color_code{i})
            hold on
            p = polyfit(timeSub,travelSub,1);
        end
        
        velocityTable(i,j) = p(1);

        plot(timeSub,polyval(p,timeSub),color = "k")
    end
end

for i = 1:3
    figure(i)
    plot(t,travel(:,i))
end

disp(velocityTable)