%% Parametros del sistema de control VTOL

% Sensibilidades
Throtle_sens = 5; % m/s^2
Yaw_sens = (20);
Roll_pich_sens = (10);

% Params bucle actitud:
phi_tau = 0.7; % segundos de la respuesta
phi_K_b = 3;
phi_f_i = 0.2;

theta_tau = 0.7; % segundos de la respuesta
theta_K_b = 3;
theta_f_i = 0.2;

psi_tau = 1.5; % segundos de la respuesta
psi_K_b = 2.5;
psi_f_i = 0.1;

% Params bucle velocidades angulares. Es el mas rapido:
p_tau = 0.3; % segundos de la respuesta
p_K_b = 6;

q_tau = 0.3; % segundos de la respuesta
q_K_b = 6;

r_tau = 0.5; % segundos de la respuesta
r_K_b = 5;

% Params de FW
Flaps_ang_deg = 0;
