load('head_projected_position.mat')
load('xy_position_2.mat')
t = SwNov01(:,1);
d = SwNov01(:,2);

x = SwNov01_xy(:,1);
y = SwNov01_xy(:,2);

close all
figure(1)
plot(t(1:end-600),d(1:end-600))

figure(2)
plot(x(1:end-600),y(1:end-600))
axis equal
% % Place a dot on every 3rd data point
% n = 1;
% v = ones(2999-600,1).*6.508./16;
% hold on
% errorbar(x(n:n:end-600),y(n:n:end-600),v,v,v,v,"r.", "MarkerSize", 20)

% Add a confidence interval around your data points. 
% we are 2x 2bin, so 1 pixel is 6.508 um. Let's say we have an accuracy
% half that. 


m = 1.64;
theta = -atan(m);

R = [cos(theta),-sin(theta);sin(theta),cos(theta)];

data = [x';y'];

dataRotated = R*data;

xR = dataRotated(1,:)';
yR = dataRotated(2,:)';

figure(3)
plot(xR(1:end-600),yR(1:end-600))
axis equal

figure(4)
plot(t(1:end-600),xR(1:end-600))
