%% VTOL initialization: 

Euler_0 = zeros(3,1);
% Condicion de vuelo
Alt_0   = input('\n\n Altura inicial (m): ');
TAS_0   = 0;

% Controles:
eta_1_0 = deg2rad(0);
eta_2_0 = deg2rad(0);
eta_3_0 = deg2rad(2.5); % 

tau_1_0 = 0.85;  %Vuelo a punto fijo
% tau_1_0= 0; % En tierra
tau_2_0 = tau_1_0;
tau_3_0 = 1*tau_1_0/cos(eta_3_0); % Si el CG_x no es 0, esto sera algo menor  que tau_1
% 0.7
%% Superficies
delta_ail_sim_0  = 0;             % Flap
delta_ail_Asim_0 = 0;             % Aleron
delta_rv_sim_0   = deg2rad(0);    % Elevator
delta_rv_Asim_0  = 0;             % Rudder

% Demix
delta_rv_L_0    = delta_rv_sim_0 + delta_rv_Asim_0;
delta_rv_R_0    = delta_rv_sim_0 - delta_rv_Asim_0;
delta_a_L_0     = delta_ail_sim_0 + delta_ail_Asim_0;
delta_a_R_0     = delta_ail_sim_0 - delta_ail_Asim_0;

%% Pasar a deflexiones de servos
Deflex2Servos