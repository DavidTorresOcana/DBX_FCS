%Setup of all the parameters of the DroneBoX

% Refer to https://docs.google.com/presentation/d/11DIR0KQ1B5zWDk-QaxDi4F0yqR4SNzSLWLUKsJZb998/edit?usp=drive_web
% and https://docs.google.com/document/d/1o5algJjx2zx0rOsJs4oOf5tWxJUKWeuXUsdHmFGMmDQ/edit

%% 1. General parameters and constants 
k_quat  = 100;  % High gain Quaternion Normalization
r_sens  = [0.0,0,0.0]' ; % Position of sensors

rho_0   = 1.225; % Density at this position % To be changed/measured/tuned
g       = 9.81;  % Gravity constant

%% 2. Mass properties, inertia moments
m_OE    = 14.5; % Con 2 baterias(2kg)
CG_OE   = [0.052,0,0.053]'; % [0.052,0,0.053]'; % CG del vehiculo vacio sin PL

             CG_OE(1) = 0; %%%% Forzar el CG_x a 0 para pruebas VTOL
             
m_PL    = 0; % PL mass  % To be changed/measured/tuned
CG_PL   = [0,0,0.18]'; % CG positions about BAC of vehicle without motors  % To be changed/measured/tuned

m   = m_OE + m_PL; 
CG  = (m_OE*CG_OE + m_PL*CG_PL)/m;

% Momentos de inercia
I_CG_OE     = [3.322,-0.028,0; -0.028,1.433,0.014; 0,0.014,4.604];
I_CG        = I_CG_OE + m_PL*[CG_PL(3)^2,0,CG_PL(1)*CG_PL(3);0,CG_PL(1)^2+CG_PL(3)^2,0;CG_PL(1)*CG_PL(3),0,CG_PL(1)^2];
I_BAC       = I_CG + m*[CG(3)^2,0,CG(1)*CG(3);0,CG(1)^2+CG(3)^2,0;CG(1)*CG(3),0,CG(1)^2];

%% 3. Arms distances   
%      1           2
%------|-----------|--------
%      |     o     |
%      |     |     |
%      |     |     |
%      |     3     |
%      |-----+-----|

% Spining direction of propellers (FROM ABOVE)
Rotation_sign   = [-1,-1,-1];   % [Anticlockwise,Anticlockwise,Anticlockwise]   % To be changed/measured/tuned

L_M             = 1.20;         % m Altura del TRIANGULO de motores
A_M             = 2/sqrt(3)*L_M; %m Distancia entre motor 1 y 2

% Distancia en +z de los ejes al plano XY del BA
    h_1     = -0.0666;% m
    h_2     = -0.0666;% m
    h_3     = -0.04824; % m
    
l_t             = 1.0845; % m Distancia del BAC al CA de la cola
% Distancias de los ejes hasta el plano de las helices Medidas en +z!!
    hp_1    = -0.089;% m
    hp_2    = -0.089;% m
    hp_3    = -0.038; % m
% Distancias de los ejes hasta el CG de los motores Medidas en +z!!
    h_M_1   = 0.04; % m
    h_M_2   = 0.04; % m
    h_M_3   = 0.02;    % m

%% 4.  Mass properties:  Arms, prop and motors
J_m     = 4.2E-4; % Inertia of motors
R       = 0.2413; % Props radius

m_prop  = 0.098;    % Mass of propelelr. To be changed/measured/tuned
m_M     = 0.74;     % Mass of motors To be changed/measured/tuned
M_eq    = m_prop/5; % Equivalent mass of the proppeller ~1/5*mass_propeller  % To be changed/measured/tuned

J_T     = J_m+1/2*M_eq*R^2; % inertia of prop + motor % To be changed/measured/tuned

I_prop  = 1/4*M_eq*R^2*diag([1,1,2]);

J_FA_1      = zeros(3);
J_FA_1(2,2) = I_prop(1,1) + m_prop*hp_1^2 + m_M*h_M_1^2;    % Momentos de inercia en los ejes F_A_1. Respecto al eje de rotacion

J_FA_2      = zeros(3);
J_FA_2(2,2) = I_prop(1,1) + m_prop*hp_2^2 + m_M*h_M_2^2;    % Momentos de inercia en los ejes F_A_2. Respecto al eje de rotacion

J_FA_3      = zeros(3);
J_FA_3(1,1) = I_prop(1,1) + m_prop*hp_3^2 + m_M*h_M_3^2;    % Momentos de inercia en los ejes F_A_3. Respecto al eje de rotacion

%% 5. Aerodynamic parameters and coefficients 
% Refer to https://docs.google.com/presentation/d/11DIR0KQ1B5zWDk-QaxDi4F0yqR4SNzSLWLUKsJZb998/edit?usp=drive_web
B_span  = 3; % m Wign Span
CMA     = 0.25; % m Mean aerodynamic chord
CMA_t   = 0.15; % m Mean aerodynamic chord of tail
Tail_inclination = deg2rad(30); % Tail planes inclination
S_w     = 0.75; % Wing wurface
S_t     = A_M*CMA_t; % m Tail plant surface 

% %Aerosonde equivalent model
% % as = aerosonde_data_mod;

% % Luis aero Model
% % DBX_aero_V1;


% Modelo Aerodinamico CFD V2(Luis-David): Se supone es muy muy preciso
%  De acuerdo al modelo aerodinamico definido en
%       Dropbox\DroneBoX\Ingeniería\03. Software y sistemas\SW\Modelado y FCS\Modelado\Modelo aerodinamico V2.docx
if input(' \n Where do you wnat aero data be load form?\n CFD files       (1) \n Aero data Sheet (2)\n ') ==1
    currr_path =pwd;
    cd ..
    cd('Modelo CFD DroneBoX')
    auto_xflow;
    cd(currr_path)
else
    fprintf('\n\n Creating Aero model tables')
    DBX_aero_V2
    
end
fprintf(' \n The static stability marging h is %4.2f%% ',...
    ( CG(1) - DBX_aero.x_CA(DBX_aero.alpha_rad==deg2rad(12),1) )/CMA*100 )

fprintf(' \n  \n Pulse una tecla para continuar... ')

pause
close all

%% 6. Propeller/motor parameters
% Go to ..\DroneBoX\Design\Props & Theo\APC thin electric 19x12 prop for finding the propeller data  and model fitting

Tau_motors  = 0.1; % Time  constant of the ESC+Motors  % To be changed/measured/tuned
v_i0=sqrt( 1/3*m*g/(2*rho_0*pi*R^2)  ); % Induced velocity in hover

% TEP normal
b       = 2; % num of blades of the props
c       = 2.6031/100; % meters mean chord of props
sigma   = b*c/(pi*R);
a       = 6.7727;  % Mean C_l slope of sections of props <~2*pi % To be changed/measured/tuned
theta_0 = 0.760787;   % Propeller pith % To be changed/measured/tuned
theta_1 = -0.6531206;     % 
C_d0    = 0.082493;    % Drag coefficient of propellers % To be changed/measured/tuned

% TEP modificada!
% C_T = sigma*a/4*( theta_0*2/3+theta_1/2  -  kappa_T*(lambda-lambda_0_T)^2 );
% C_Q = sigma*a/4*( theta_0*2/3+theta_1/2  -  kappa_Q*(lambda-lambda_0_Q)^2 )*kappa_Q*(lambda-lambda_0_Q)^2+ sigma*c_d_0/8;
a           = 4.0152;
c_d_0       = 0.2;
lambda_0_T  = 0.0462;
kappa_T     = 4.2976;
lambda_0_Q  = 0.1155;
kappa_Q     = -3.7711;

% Load the AB model of induced velocities. Propeller model
load('ABModelDimless.mat')
figure
[X,Y]=meshgrid(Vx_adim,Vz_adim);
surf(X,Y,v_i_adim');
hold on;
scatter3(0,0,1.16,'filled','LineWidth',20);
hold off;
legend('Dimless induced velocoty','Hover position')
xlabel('V_x Dimless')
ylabel('V_z Dimless')
zlabel('V_i Dimless')

% Compute RAND model of induced velocities. Propeller model
clear v_i_adim
v_i_adim_f = @(v_z_adim,v_x_adim) v_ia_adim(v_z_adim)/sqrt( 1 + (v_x_adim)^2 );

for i=1:size(Vx_adim,2)
    for j=1:size(Vz_adim,2)
        v_i_adim(i,j) = v_i_adim_f(Vz_adim(j),Vx_adim(i));
    end
end
figure
[X,Y]=meshgrid(Vx_adim,Vz_adim);
surf(X,Y,v_i_adim');
hold on;
scatter3(0,0,1.16,'filled','LineWidth',20);
hold off;
legend('Dimless induced velocoty','Hover position')
xlabel('V_x Dimless')
ylabel('V_z Dimless')
zlabel('V_i Dimless')

% Load the Torque-Throttle-Omega model of ESC+motor : Modelo original
Ref_volt=30;% Reference voltage

load('TTO_map.mat')% To be changed/measured/tuned
figure
surf(repmat(Torque_TTO,size(Throtle_TTO,2),1)',repmat(Throtle_TTO',1,size(Torque_TTO,2))',Omega_TTO')
Torque_TTO_vec=Torque_TTO(1,:);
Throtle_TTO_vec=Throtle_TTO(1,:);

% Datos modelo TTO Raw
hold on
load('TTO_raw_data.mat')
plot3(Mom,throtle,Omega,'or')

xlabel(' Torque (N.m)')
ylabel(' Equivalent throtle (V)')
zlabel(' Omega (rad/s)')
legend('TTO map','Test bench')
% Load the Throttle-Omega model of ESC+motor 
load('TO_curve.mat')


