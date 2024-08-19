clear; close all
format long
toggle_print = 1;
heave = 1;
twist = 1;

load('SwNov01_digital_twin_input_v2.mat')
    
%% number of discretization points
nX = 1000; % number of points along tail length

%% tail dimensions and material properties
% PNAS neuroswimmer had b=70um and h~=10.7um
L = 5600; % tail length [um]
b = 140; % tail width [um]
h = 100; % tail thickness [um]
E = 1.7; % PDMS elastic modulus [MPa = uN/um^2]
I = (b*(h^3))/12; % moment of inertia [um^4]
A = E*I; % flexural rigidity [uN*um^2]

%% fluid properties
mu = 1.15; % viscosity of 50:50 Percoll:media mixture at 37C [mPa*s]
mu = mu*1e-9; % [uN*s/um^2]
rho = 0.993; % density of water at 37C [g/mL = g/cm^3]
rhoPercoll = 1.13; % density of Percoll at 25C [g/mL = g/cm^3]
rho = (rho+rhoPercoll)/2; % estimated density of 50:50 Percoll:media mixture
rho = rho*1e3; % [kg/m^3]

%% parameters for head drag estimation
headRadius = 969; % [um]
K = 1;

%% tail drag coefficients
r = 0.5*sqrt(b*h); % equivalent tail radius
ZN = (4*pi*mu)/(log(L/r)+0.193); % normal drag coefficient [uN*s/um^2]
ZT = (2*pi*mu)/(log(L/r)-0.807); % tangential drag coefficient [uN*s/um^2]



%% actuation function (muscle contraction dynamics)
% Use interpolation of a lookup table to make functions
time_data = data(:,1);
heave_data = -(data(:,2)-min(data(:,2))); % um
twist_data = (data(:,3)-60)*pi/180; % rad

actFuncTwist = @(tq) interp1(time_data,twist_data,tq);
actFuncHeave = @(tq) interp1(time_data,heave_data,tq);

figure(18)
plot(time_data, heave_data)
figure(19)
plot(time_data,twist_data)

%% discretization
x = linspace(0,L,nX); x = x';
t = min(time_data):0.05:max(time_data); t = t';

%% Solving for y(x,t)
Yxt = tailDeformation_v2(x,t,A,ZN,actFuncTwist,actFuncHeave,twist,heave); % [um]

%% Calculating propulsion force and swimming speed
numberOfTails = 2;
%K = 42.6*10^-6;  %uN*s/um Experimental fit to deceleration
K = 9.6*10^-6;  %uN*s/um Only tails prediction
%K = 75.8*10^-6;  %uN*s/um Overall prediction
% headRadius = 2500; %um
% D = numberOfTails*ZT*L;
disp("Drag coefficient")
disp(K)

[F,Ux,X] = propulsionCalc_v2(numberOfTails,x,t,L,Yxt,ZN,ZT,mu,headRadius,K); % [uN, um/s, um]

%% Plotting swimmer travel
figure(8);
plot(t,X(1,:))

%% Printing results
% %velocity = mean(Ux(2*nT+1:end)); % time-averaged swimming speed [um/s]
% force = mean(F*1e3); % time-averaged propulsion force per tail [nN]
% Sp = L*((A/(ZN*omega))^(-1/4)); % Sperm number
% %Re = (1e-18)*abs(rho*velocity*L)/mu; % Reynolds number
% if toggle_print==1
%     %fprintf('mean swimming velocity = %5.2f um/s\n',velocity)
%     fprintf('mean thrust per tail = %8.6f nN\n',force)
%     fprintf('Sperm number = %5.2f\n',Sp)
%     %fprintf('Reynolds number = %7.5f\n',Re)
% end






