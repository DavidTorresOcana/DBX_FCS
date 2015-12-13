%% FW initialization
Euler_0=zeros(3,1);
% Condicion de vuelo
Alt_0 = input('Alttura inicial (m): ');
% TAS_0 = input('TAS inicial (m/s): ');
TAS_0 = 25;
% Euler_0(2) = deg2rad( input('AoA inicial (deg): ') );
Euler_0(2) = deg2rad(2);
Euler_0_2  = Euler_0(2);

% Controles:
tau_1_0= 0.5;
tau_2_0 = tau_1_0;
tau_3_0 = 0;

eta_1_0 = -deg2rad(90);
eta_2_0 = -deg2rad(90);
eta_3_0 = deg2rad(0);

delta_ail_sim_0 = 0;             % Flap
delta_ail_Asim_0 = 0;            % Aleron
delta_rv_sim_0 = deg2rad(-8);   % Elevator
delta_rv_Asim_0 = 0;             % Rudder
% Demix
delta_rv_L_0 = delta_rv_sim_0 + delta_rv_Asim_0;
delta_rv_R_0 = delta_rv_sim_0 - delta_rv_Asim_0;
delta_a_L_0  = delta_ail_sim_0 + delta_ail_Asim_0;
delta_a_R_0  = delta_ail_sim_0 - delta_ail_Asim_0;
% Pasar a deflexiones de servos
Deflex2Servos