function [F,U,X] = propulsionCalc_v2(numberOfTails,x,t,L,Yxt,ZN,ZT,mu,headRadius,K)
format long

p = length(x);
q = length(t);
dx = x(2)-x(1);
dt = t(2)-t(1);

% total propulsion force of one tail
F = zeros(1,q);
% swimming speed
U = zeros(1,q);
% X coordinates translated according to swimming speed
X = zeros(p,q);
X(:,1) = x';

DX = zeros(p,p);
DX(1,1:3) = [-3/2 2 -1/2]/dx;
DX(p,p-2:p) = [1/2 -2 3/2]/dx;
for i = 2:p-1
    DX(i,i-1:i+1) = [-1/2 0 1/2]/dx;
end

for i = 2:q-1
    Yx = DX*Yxt(:,i);
    Yt = (0.5*Yxt(:,i+1)-0.5*Yxt(:,i-1))/dt;
    F(i) = sum((ZN-ZT)*Yt.*Yx*dx);
    if K ~= 1
        U(i) = numberOfTails*F(i)/K;
    else
        U(i) = numberOfTails*F(i)/(numberOfTails*ZT*L+6*pi*mu*headRadius);
        disp("Your code isn't working")
    end
    
    X(:,i) = X(:,i-1)+U(i-1)*dt;
end

Yx_end = DX*Yxt(:,q);
Yt_end = (0.5*Yxt(:,q-2)-2*Yxt(:,q-1)+1.5*Yxt(:,q))/dt;
F(q) = sum((ZN-ZT)*Yt_end.*Yx_end*dx);
if K ~= 1
    U(q) = numberOfTails*F(q)/K;
else
    U(q) = numberOfTails*F(q)/(numberOfTails*ZT*L+6*pi*mu*headRadius);
    disp("Your code isn't working")
end

X(:,q) = X(:,q-1)+U(q-1)*dt;
end


