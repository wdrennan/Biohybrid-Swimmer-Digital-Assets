function [Yxt] = tailDeformation_v2(x,t,A,ZN,actFuncTwist,actFuncHeave,twist,heave)
format long

p = length(x);
q = length(t);
dx = x(2)-x(1);
dt = t(2)-t(1);

Yxt = zeros(p,q);
D4 = zeros(p,p);
Dt = zeros(p,p);
B = zeros(p,p);
C = zeros(p,q);

for i = 3:p-2
    D4(i,i-2:i+2) = A*[1 -4 6 -4 1]/dx^4;
    Dt(i,i) = ZN/dt;
end

% Left BCs (free)
B(1,1:4) = A*[2 -5 4 -1]/dx^2;
B(2,1:5) = A*[-5/2 9 -12 7 -3/2]/dx^3;
C(1:2,:) = 0;

% Right BCs (fixed/actuated)
B(p-1,p-2:p) = 1*[1/2 -2 3/2]/dx;
B(p,p) = 1;
if(twist==0), C(p-1,:) = 0; end
if(twist==1), C(p-1,:) = actFuncTwist(t); end
if(heave==0), C(p,:) = 0; end
if(heave==1), C(p,:) = actFuncHeave(t); end

B = B + D4 + Dt;

[L,U] = lu(B);

Yxt(:,1) = C(p,1) - (x(end)-x)*C(p-1,1);

for i=2:q
    C(3:p-2,i) = C(3:p-2,i) + Yxt(3:p-2,i-1)*ZN/dt;
    d = L\C(:,i);
    Yxt(:,i) = U\d;
    % if rem(i,75) == 0
    %     disp("Heave: " + C(p,i) + " [um]");
    %     disp("Twist: " + C(p-1,i)*180/pi + " [DEG]");
    %     disp(i + " of " + q)
    % end
end

% This is solve By = c. It does not know that B is the same for each loop step, so we will factor B. B = LU
% That way, LUy = c
% Let Uy = d
% Let Ld = c
% Solve for d then solve for y. 

