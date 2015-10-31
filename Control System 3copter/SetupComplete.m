%Setup of all the parameters of the 3copter
% clear all
close all
clc

addpath(genpath('ESC+Motor Model'));
%% General parameters
k_quat=100;  % High gain Quaternion Normalization
r_sens = [0,0,0.03]' ; % Position of sensors

%% Mass properties, inertia moments
m=3.51; % Total Mass   % To be changed/measured/tuned
m_0=  2.61; % Mass of vehicle without motors
CG_0= [0,0,0.02]'; % CG positions about BAC of vehicle without motors  % To be changed/measured/tuned
M_eq=0.001; % Equivalent mass of the proppeller ~1/5*mass_propeller  % To be changed/measured/tuned

Ix=0.0552; % To be changed/measured/tuned
Iy=0.0552; % To be changed/measured/tuned
Iz=0.11;   % To be changed/measured/tuned
Ixz = 0.005; % To be changed/measured/tuned
I_BAC_0= [ Ix,0,Ixz;0,Iy,0;Ixz,0,Iz];

%% Arms distances   
%           1
%           |
%           o
%           |
%     3-----o-----2
Rotation_sign = [ 1,-1,-1]; % [Clockwise,Anticlockwise,Anticlockwise]   % To be changed/measured/tuned
l=0.345; % Distance of propeler from origin. Arm lenght % To be changed/measured/tuned
h= 0.08; % vertical distance of the propellers form origin  % To be changed/measured/tuned
l_arm = 0.264;
h_FA = 0.02;
h_M  =  0.064; 

%% Mass properties:  Arms, prop and motors
J_m=4.2E-6; % inertia of motors
R=0.1778; % Props radius
J_T=J_m+1/2*M_eq*R^2; % inertia of prop +motor % To be changed/measured/tuned

m_prop = 0.02; % To be changed/measured/tuned
m_M = 0.300; % To be changed/measured/tuned
m_FA = 0.02; % To be changed/measured/tuned
M_tube = 0.04; 
R_tube_eq= 0.015;

I_prop=1/4*M_eq*R^2*diag([1,1,2]);
% % % I_tube = [1/2*M_tube*R_eq^2,0,??;...
% % %           0 ,1/3*M_tube*l_arm^2,0;...
% % %           ??,0,1/3*M_tube*l_arm^2];
I_tube = [1/2*M_tube*R_tube_eq^2,0,  0  ;...
          0 ,1/3*M_tube*l_arm^2,0;...
            0  ,0,1/3*M_tube*l_arm^2];
J_FA = I_prop(1,1) + m_prop*h^2  + m_FA*h_FA^2 + m_M*h_M^2;    

%% Propeller/motor parameters
% Go to ..\Small 3-copter\data\14x4.7 prop for finding the propeller data  and model fitting
Tau_motors = 0.01; % Time  constant of the ESC+Motors  % To be changed/measured/tuned

b=2; % num of blades of the props
c=3/100; % meters mean chord of props
sigma=b*c/(pi*R);
a=10.26;  % Mean C_l slope of sections of props <~2*pi % To be changed/measured/tuned
theta_0=0.38397;   % Propeller pith % To be changed/measured/tuned
theta_1=-0.2967;     % 
C_d0=0.001193;    % Drag coefficient of propellers % To be changed/measured/tuned
%% Aerodynamic coefficients.
% They try to represents the aerodynamic influence of the vehicle moving
% across the air.  They can be perfectly 0 in first aprox.
C_x=1.2;
C_y=C_x;
A_x=0.015;
A_y=A_x;
C_z=2.2;
A_z=0.16;

%% General parameters of the quadcopter
rho=1.15; % Density at this position % To be changed/measured/tuned
g=9.81;
v_i0=sqrt( 1/3*m*g/(2*rho*pi*R^2)  ); % Induced velocity in hover

%% Load the AB model of induced velocities. Propeller model

load('ABModelDimless.mat')

% % % [X,Y]=meshgrid(Vx_adim,Vz_adim);
% % % surf(X,Y,v_i_adim');
% % % hold on;
% % % scatter3(0,0,1.16,'filled','LineWidth',20);
% % % hold off;
% % % legend('Dimless induced velocoty','Hover position')
% % % xlabel('V_x Dimless')
% % % ylabel('V_z Dimless')
% % % zlabel('V_i Dimless')

%% Load the Torque-Throttle-Omega model of ESC+motor 
Ref_volt=16;% Reference voltage

load('TTO_map.mat')% To be changed/measured/tuned
figure
surf(Throtle_TTO,Torque_TTO,Omega_TTO)
Torque_TTO_vec=Torque_TTO(:,1);
Throtle_TTO_vec=Throtle_TTO(1,:);


%% Load the Throttle-Omega model of ESC+motor 
load('TO_curve.mat')


