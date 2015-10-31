%% Aerosonde Trim and Linearize
% Trim and linearize an Aerosonde in Simulink
%
%
% Determine the trim conditions and derive linear
% state-space models directly for the Aerosonde model


%% Initialize Aerosonde Model data 

aerosonde=aerosonde_data;

%% Define initial state values for trim routine

position_ini = [0; 0; -1000];  %  position in inertial axes [Xe,Ye,Ze]: (m)
velocity_ini = [24.95;   0;   1.4];     %  velocity in body axes [u,v,w]: (m/s), yaw]: (rad)
rates_ini = [0; 0; 0];         %  body rotation rates [p,q,r]: (rad/s)
euler_ini = [0;  0.0564; 0];         %  Euler orientation [roll, pitch, yaw]: (rad)
fuel_ini = 2;                  %  fuel mass: (Kg)
Omega_ini = 5236*pi/30;        %  engine speed: (rad/s); 
 
%% Find names and ordering of states from Simulink model.

[sizes,x0,names]=aerosonde_trim;
disp('check order of state variables')
names{:}
% 1 - ub,vb,wb
% 2 - ub,vb,wb
% 3 - ub,vb,wb
% 4 - xe,ye,ze
% 5 - xe,ye,ze
% 6 - xe,ye,ze
% 7 - p,q,r 
% 8 - p,q,r 
% 9 - p,q,r 
% 10 - Fuel Integrator
% 11 - phi,theta,psi
% 12 - phi,theta,psi
% 13 - phi,theta,psi
% 14 - Engine speed Integrator 

%% trim for fixed input - find output and states for a set of inputs 
if(0)
    disp('fixed controls - no sideslip')
    dxfix = [1 2 3   5 6 7 8 9   11 12 13 14];% do not fix ground position rate and mass change rate
    xfix = [10];% ensure mass is at required value
    % trim to get no sideslip
    yfix=[2 3]; % beta, h fixed
    yini=[25; 0; 1000]; % airspeed, beta, h
    % set the initial control  
    ufix=[1 2 3 4];
    uini=[0.155; 0; 0; 0.5]; % elevator, aileron, rudder, throttle
    % set initial states and rates
    xini=[ velocity_ini; position_ini;rates_ini; fuel_ini; euler_ini; Omega_ini];
    dxini=[0;0;0;yini(1);0;0;0;0;0;0;0;0;0;0];
    % trim the aircraft
    [xtrim,utrim,ytrim,dxtrim]=trim('aerosonde_trim',xini,uini,yini,[],ufix,[],dxini,dxfix)
    
end %if

%% find the deflections and throttle to trim the aircraft at wings level horizontal flight
if(1)
    disp('horizontal steady state ')
    dxfix = [1 2 3   5 6 7 8 9   11 12 13 14];% do not fix ground position rate and mass change rate
    xfix = [10]; % ensure mass is at required value
    % trim airspeed and altitude
    yfix=[1 2 3];
    yini=[25; 0; 1000]; % airspeed, beta, h
    % set the initial control to
    uini=[0; 0; 0; 0.7]; % elevator, aileron, rudder, throttle
    % set initial states and rates
    xini=[ velocity_ini; position_ini;rates_ini; fuel_ini; euler_ini; Omega_ini];
    dxini=[0;0;0;yini(1);0;0;0;0;0;0;0;0;0;0];
    % trim the aircraft
    [xtrim,utrim,ytrim,dxtrim]=trim('aerosonde_trim',xini,uini,yini,xfix,[],yfix,dxini,dxfix) 
end %if


%% linearize the system about  trim condition
[A,B,C,D]=linmodv5('aerosonde_trim',xtrim,utrim)
%and check the stability of the system by \\
eig(A)
 
%% test the trim
control_0 = [0;utrim;13;1]      % [flap, elevator, aileron, rudder, throttle, mixture, ignition]
position_ini = [0; 0; -1000];   %  position in inertial axes [Xe,Ye,Ze]: (m)
velocity_0 = xtrim(1:3);        %  velocity in body axes [u,v,w]: (m/s), yaw]: (rad)
rates_0 = xtrim(7:9);           %  body rotation rates [p,q,r]: (rad/s)
euler_0 = xtrim(11:13);         %  Euler orientation [roll, pitch, yaw]: (rad)
fuel_0 = xtrim(10);             %  fuel mass: (Kg)
Omega_0 = xtrim(14);            %  engine speed: (rad/s);
% now run aerosonde model
disp('now run aerosonde model for short time to check trim')