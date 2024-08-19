close all
x = -data(:,1)
y = data(:,2)
plot(x,y)

m = 1.64;
theta = -atan(m);

R = [cos(theta),-sin(theta);sin(theta),cos(theta)];

data2 = [x';y'];

dataRotated = R*data2;

xR = dataRotated(1,:)';
yR = dataRotated(2,:)';

figure(3)
plot(xR,yR)
axis equal

figure(4)
t = 0.05:0.05:(length(xR)*0.05)
plot(t,xR)