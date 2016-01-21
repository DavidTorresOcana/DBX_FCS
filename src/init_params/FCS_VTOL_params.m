%% Parametros del sistema de control VTOL
% NO OLVIDAR METER ESTOS PARAMETROS
%   EN EL ARCHIVO DE INICIALIZACION DE PX4!!!!

%% Sensibilidades
Throtle_sens = 7; % m/s^2
Yaw_sens = (20);
Roll_pich_sens = (15);

%% Params bucle actitud:
phi_tau = 0.15; % segundos de la respuesta
phi_K_b = 3; %
phi_f_i = 0.5;

theta_tau = 0.15; % segundos de la respuesta
theta_K_b = 3;
theta_f_i = 0.5;

psi_tau = 4; % segundos de la respuesta
psi_K_b = 2.5;
psi_f_i = 0.1;

%% Params bucle velocidades angulares. Es el mas rapido:
p_tau = 0.05; % segundos de la respuesta
p_K_b = 5;

q_tau = 0.05; % segundos de la respuesta
q_K_b = 5;

r_tau = 0.1; % segundos de la respuesta
r_K_b = 5;

% Params de FW
Flaps_ang_deg = 0;


%% Classical contorl for tafe off (PIDs):
PID_theta_Kp = 3;
PID_phi_Kp = 3;
PID_theta_Ki = 0.1;
PID_phi_Ki = 0.1;
PID_theta_Kd = 0;
PID_phi_Kd = 0;
PID_theta_dot_Kp = 0.2;
PID_phi_dot_Kp = 0.2;
PID_theta_dot_Ki = 0;
PID_phi_dot_Ki = 0;
PID_theta_dot_Kd = 0;
PID_phi_dot_Kd = 0;
