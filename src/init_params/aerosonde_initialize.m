%aerosonde_initialize.m
%   Aerosonde UAV Initialization Routine
%   
%   Copyright 2002 Unmanned Dynamics, LLC 
%   Modified JFW using Mathworks Aerospace Blockset 2 March 2011
%   For internal use only

% add ell4 path
%path(path,'C:\Documents and Settings\eh3081\My Documents\MATLAB\ATRAEAII\ell4')
%%  obtain aircraft data 
aerosonde=aerosonde_data
 

%% Define initial state values  

theta_trim = 0;
q_trim =0;
chi_trim = 0;               % initial heading
h_trim=500;                % initial altitude

position_0 = [0; 0; -h_trim]%  position in inertial axes [Xe,Ye,Ze]: (m)
velocity_0 = [23; 0; 0]     %  velocity in body axes [u,v,w]: (m/s), yaw]: (rad)
rates_0 = [0; q_trim ; 0]   %  body rotation rates [p,q,r]: (rad/s)
euler_0 = [theta_trim; 0; 0]%  Euler orientation [roll, pitch, yaw]: (rad)
fuel_0 = 2                  %  fuel mass: (Kg)
Omega_0 = 5000*pi/30        %  engine speed: (rad/s); 
 
%% Define controls  

% controller initial states
flap= 0;
mixture = 13;
ignition = 1;
eta_trim=-0.1;   % elevator
xi_trim=0;       % aileron
zeta_trim=0;     % rudder
tau_trim=0.4;    %throttle
 
%for open loop case
control_0 = [flap; % flap
    eta_trim;      % elevator
    xi_trim;       % aileron
    zeta_trim;     % rudder
    tau_trim;      % throttle
    mixture;       % mixture
    ignition];     % ignition (1=on)

%% Define controller gains for closed loop case
% designed by Deborah Saban 
% see D. Saban, "Wake Vortex Modelling and Simulation for Air Vehicles  
%    in Close Formation Flight", PhD Thesis, Cranfield University, 
%    April 2010 (Supervisor: Dr James F Whidborne)

% SAS
Kq_eta = -0.28;
Ktheta_eta = -1;
Kr_zeta = -0.25;
Tr = 0.75;
Kphi_xi = -0.2;
Kari = 0.5;

% Attitude Control
Kp_theta = -0.8;
Ki_theta = -0.8;
Kp_phi = -0.2;
Ki_phi = -0.1;

% Autopilot
Kp_Ze = -0.03;
Ki_Ze = -0.0001;
Kd_Ze = -0.05;
Kp_psi = 0.7;
Ki_psi = 0.001;
Kp_u = 0.5;
Ki_u = 0.15;

% Trajectory Tracker
Kp_Ye = 0.18;
Ki_Ye = 0.0025;
Kd_Ye = 0.6;
Kp_Xe = 0.125;


%%   Virtual Leader (trajectory reference)
% straight line flight heading north (X_e-direction)

Xe0_VL=position_0(1);
Ye0_VL=position_0(2);
Ze0_VL=position_0(3);

Ue_VL=25;
Ve_VL=0;
We_VL=0;

%% FlightGear Visualization

% Cranfield Airport
% airport_ID : EGTC
% runway_ID : 1
latitude  = 52.073105 
longitude = -000.616697

% San Fransisco Airport
% airport_ID : KSFO
% runway_ID : 10L
% latitude  = 37.76   
% longitude = -122.4

% get machine that Flightgear will run on
% host machine is 127.0.0.1
% 
%java.net.InetAddress.getByName('SOXP13426C')% 


