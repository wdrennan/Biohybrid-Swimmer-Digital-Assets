clear; close all;
load('day_6_release_exp_curve.mat')


options = optimoptions('lsqcurvefit', ...
    'MaxFunctionEvaluations', 1000, ...
    'FunctionTolerance', 1e-8, ...  % Set the function tolerance
    'StepTolerance', 1e-8, ...      % Set the step tolerance
    'OptimalityTolerance', 1e-8);   % Set the optimality tolerance

t = data(1:end-2,1)
y = data(1:end-2,2)




f = @(x, tdata) -x(1)*exp(-(tdata-t(1))/x(2)) + x(3);

x0 = [1,0.18,0];
x = lsqcurvefit(f,x0,t,y, [0.1, 0.05, -1000], [1000,1,1000], options);

x

plot(t,y,".--"); hold on

th = t(1):0.01:t(end);
plot(th,f(x,th))

