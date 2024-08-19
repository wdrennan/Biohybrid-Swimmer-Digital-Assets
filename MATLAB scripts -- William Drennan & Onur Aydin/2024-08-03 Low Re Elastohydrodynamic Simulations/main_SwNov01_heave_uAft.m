clear
format long
toggle_print = 1;
heave = 1;
twist = 1;

load('SwNov01_x3_inputs.mat')
t = data(:,1);

p_x2_of_x3 = [0.000618258,0.83063297,-1.783892396];
p_theta_of_x3 = [-0.00021897,0.165247374,-0.970497407];
x3_0 = 163.4;

twistList = 0.2:0.2:8; % DEG

frequencyCount = length(data(1,:))-1;
twistCount = length(twistList);

twistAmplitudeTable = zeros(twistCount,frequencyCount);
velocityTable = zeros(twistCount,frequencyCount);
waveformTable = cell(twistCount,frequencyCount);

% Run a given frequency 
for iFrequency = 1:frequencyCount
    % Run a given pair of heave and twist
    x3_waveform = data(:,iFrequency+1);
    for iTwist = 1:twistCount
        targetTwist = twistList(iTwist);
        % number of discretization points
        nX = 1000; % number of points along tail length
        
        % tail dimensions and material properties
        % PNAS neuroswimmer had b=70um and h~=10.7um
        L = 5600; % tail length [um]
        b = 140; % tail width [um]
        h = 100; % tail thickness [um]
        E = 1.7; % PDMS elastic modulus [MPa = uN/um^2]
        I = (b*(h^3))/12; % moment of inertia [um^4]
        A = E*I; % flexural rigidity [uN*um^2]
        
        % fluid properties
        mu = 1.15; % viscosity of 50:50 Percoll:media mixture at 37C [mPa*s]
        mu = mu*1e-9; % [uN*s/um^2]
        rho = 0.993; % density of water at 37C [g/mL = g/cm^3]
        rhoPercoll = 1.13; % density of Percoll at 25C [g/mL = g/cm^3]
        rho = (rho+rhoPercoll)/2; % estimated density of 50:50 Percoll:media mixture
        rho = rho*1e3; % [kg/m^3]
        
        % parameters for head drag estimation
        %K = 9.6*10^-6;  %uN*s/um Experimental fit to deceleration
        headRadius = 2500; % um
        K = 42.6*10^-6;  %uN*s/um Overall prediction
        
        % tail drag coefficients
        r = 0.5*sqrt(b*h); % equivalent tail radius
        ZN = (4*pi*mu)/(log(L/r)+0.193); % normal drag coefficient [uN*s/um^2]
        ZT = (2*pi*mu)/(log(L/r)-0.807); % tangential drag coefficient [uN*s/um^2]
        
        
        
       
        
        % Find scalingFactor such that
        % polyval(p_theta_of_x3,scalingFactor*x3_waveform + x3_0) has the
        % correct targetTwist
        [scalingFactor, twistAmplitude] = getScalingFactor(p_theta_of_x3,x3_waveform,x3_0,targetTwist, 0.1);
        if scalingFactor == 0
            disp("reduce the tolerance")
            break
        end
    
        % actuation function (muscle contraction dynamics)
        % Use interpolation of a lookup table to make functions
        time_data  = t;
        heave_data = polyval(p_x2_of_x3,scalingFactor*x3_waveform + x3_0); 
        heave_data = -(heave_data - min(heave_data)); %um
        twist_data = (polyval(p_theta_of_x3,scalingFactor*x3_waveform + x3_0)-60)*pi/180; % rad
        
        actFuncTwist = @(tq) interp1(time_data,twist_data,tq);
        actFuncHeave = @(tq) interp1(time_data,heave_data,tq);
        
        % discretization
        x = linspace(0,L,nX); x = x';
        t = min(time_data):0.05:max(time_data); t = t';
        
        % Solving for y(x,t)
        Yxt = tailDeformation_v2(x,t,A,ZN,actFuncTwist,actFuncHeave,twist,heave); % [um]

        % Calculating propulsion force and swimming speed
        numberOfTails = 2;
        [F,Ux,X] = propulsionCalc_v2(numberOfTails,x,t,L,Yxt,ZN,ZT,mu,headRadius,K); % [uN, um/s, um]
        velocity = mean(Ux(end-100:end-20)); % time-averaged swimming speed [um/s]
        velocityTable(iTwist,iFrequency) = velocity;
        waveformTable{iTwist,iFrequency} = Ux;
        twistAmplitudeTable(iTwist,iFrequency) = twistAmplitude;
        runCount = (iFrequency-1)*50+iTwist;
        disp(runCount);
        
        ROI = (t > 2.5 & t < 6.5);
        timeSub = t(ROI);
        travelSub = X(1,ROI);
        travelLB = movmin(travelSub,10);
        p = polyfit(timeSub,travelLB,1);
        if sum(runCount == [25,96,105,178,245,265]) ~= 0
            figure(1)
            plot(timeSub,travelSub, color = "b")
            hold on
            plot(timeSub,travelLB, color = "r")
            plot(timeSub,polyval(p,timeSub),color = "k")
            disp("Look at the graph")
        end
        velocityTable(iTwist,iFrequency) = p(1);

    end
end

% %%
% for iFrequency = 1:frequencyCount
%     % Run a given pair of heave and twist
%     for iTwist = 1:twistCount
%         Ux = waveformTable{iTwist,iFrequency};
%         velocity = mean(Ux(20:110));
%         velocityTable(iTwist,iFrequency) = velocity;
%     end
% end

%%
figure(1)
for_excel = []
for i = 1:frequencyCount
    plot(twistAmplitudeTable(:,i),velocityTable(:,i))
    for_excel(:,2*i-1) = twistAmplitudeTable(:,i);
    for_excel(:,2*i)   = velocityTable(:,i);
    hold on
end
% 
% % number of discretization points
% nX = 1000; % number of points along tail length
% 
% % tail dimensions and material properties
% % PNAS neuroswimmer had b=70um and h~=10.7um
% L = 5600; % tail length [um]
% b = 140; % tail width [um]
% h = 100; % tail thickness [um]
% E = 1.7; % PDMS elastic modulus [MPa = uN/um^2]
% I = (b*(h^3))/12; % moment of inertia [um^4]
% A = E*I; % flexural rigidity [uN*um^2]
% 
% % fluid properties
% mu = 1.15; % viscosity of 50:50 Percoll:media mixture at 37C [mPa*s]
% mu = mu*1e-9; % [uN*s/um^2]
% rho = 0.993; % density of water at 37C [g/mL = g/cm^3]
% rhoPercoll = 1.13; % density of Percoll at 25C [g/mL = g/cm^3]
% rho = (rho+rhoPercoll)/2; % estimated density of 50:50 Percoll:media mixture
% rho = rho*1e3; % [kg/m^3]
% 
% % parameters for head drag estimation
% headRadius = 4500; % [um]
% K = 1;
% 
% % tail drag coefficients
% r = 0.5*sqrt(b*h); % equivalent tail radius
% ZN = (4*pi*mu)/(log(L/r)+0.193); % normal drag coefficient [uN*s/um^2]
% ZT = (2*pi*mu)/(log(L/r)-0.807); % tangential drag coefficient [uN*s/um^2]
% 
% 
% 
% % actuation function (muscle contraction dynamics)
% % Use interpolation of a lookup table to make functions
% time_data = SwNov01_digital_twin_input(:,1);
% heave_data = -SwNov01_digital_twin_input(:,2); % um
% twist_data = SwNov01_digital_twin_input(:,3)*pi/180; % rad
% 
% actFuncTwist = @(tq) interp1(time_data,twist_data,tq);
% actFuncHeave = @(tq) interp1(time_data,heave_data,tq);
% 
% % discretization
% x = linspace(0,L,nX); x = x';
% t = min(time_data):0.05:max(time_data); t = t';
% 
% % Solving for y(x,t)
% Yxt = tailDeformation_v2(x,t,A,ZN,actFuncTwist,actFuncHeave,twist,heave); % [um]

% %% Calculating propulsion force and swimming speed
% numberOfTails = 2;
% headRadius = 4500; % um
% [F,Ux,X] = propulsionCalc_v2(numberOfTails,x,t,L,Yxt,ZN,ZT,mu,headRadius,K); % [uN, um/s, um]
% 
% %% Plotting swimmer travel
% figure(8);
% plot(t,X(1,:))
% 
% %% Printing results
% velocity = mean(Ux(2*nT+1:end)); % time-averaged swimming speed [um/s]
% force = mean(F*1e3); % time-averaged propulsion force per tail [nN]
% Sp = L*((A/(ZN*omega))^(-1/4)); % Sperm number
% Re = (1e-18)*abs(rho*velocity*L)/mu; % Reynolds number
% if toggle_print==1
%     fprintf('mean swimming velocity = %5.2f um/s\n',velocity)
%     fprintf('mean thrust per tail = %8.6f nN\n',force)
%     fprintf('Sperm number = %5.2f\n',Sp)
%     fprintf('Reynolds number = %7.5f\n',Re)
% end






