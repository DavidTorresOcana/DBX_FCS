%% Run DBX simulation model and control design suite
% 
% Refer to Vehcile Design Performance Calculations in:
% https://docs.google.com/spreadsheets/d/1kxwsmLT4YgUCwGdfR9G-QyIUT7LxyUGQya-37hGkW4Q/edit?usp=drive_web
clear all
close all
clc

fprintf(' \n\n  Welcome to DBX modelling, simulation \n      and control design suite')

addpath(genpath('Used Functions'),genpath('Control'),genpath('Init and params'),genpath('Modelo dinamico'),genpath('../Libraries'),genpath('../Modelo CFD DroneBox'))

T_sim  = 0.01; % Freq simulacion
T_ctrl = 0.01;  % Freq FCS
load('Model_init_cond_Bus.mat')
load('Model_output_Bus.mat')
%% 1.  Load data of airframe
fprintf(' \n\n\n Loading airframe data and parameters')

DBX_airframe_setup;

%% 2. Ruido y caracterizacion sensores
fprintf(' \n Loading sensor parameters')

Sensor_params;

%% 3. Calibracion servos y superficies moviles
fprintf(' \n Loading servos & motors calibration \n   and PWM parameters')

%calibracion de servos y ESC
Servos_calib;

% Nivel de cuantitacion en PWM
DBX_PWM.quant_interval      = 5; % Resolucion de la señal PWM
DBX_PWM.Motors.Max_PWM      = 2100; % us
DBX_PWM.Motors.Min_PWM      = 900; % us
DBX_PWM.Motors.update_rate  = 50; % Hz

DBX_PWM.Servos.Max_PWM      = 2100; % us
DBX_PWM.Servos.Min_PWM      = 900; % us
DBX_PWM.Servos.update_rate  = 50; % Hz
%% 4. Simulation initialization
fprintf(' \n  Initializing the simulation')

% fprintf(' \n Trimming')
% Triming_routine;

% FW_init;
VTOL_init;

% Airport/Origin point
latitude    =  40.463650;
longitude   = -3.554389;
airport_alt = 587.5; % m

% latitude=50.0630793;
% longitude=19.9338941;

[~, ~, ~, rho] = atmosisa(airport_alt);
%% 5. Initialize actuators
fprintf(' \n  Initializing actuators')

Init_motors;

%% 6. FCS params
fprintf(' \n Loading FCS parameters')

% FCS_fw_params;

FCS_VTOL_params;
% Control allocator settings
epsilon     = 0.01; % Perturbation size for CA gradient computation

% Limits of the vehicle dynamics
% Accelerations: Generate at least 1g vertical

Max_Omega   = fitresult_TO(Ref_volt);
Max_Thrust  = rho*pi*R^2*(Max_Omega*R)^2*0.015; % Aprox Conservative
A_z_max     = Max_Thrust*3/m;
A_l_max_x   = sqrt( (Max_Thrust*2/m)^2  -  (g*2/3)^2  );

%% 8. Checking for models versions
% Do version contorl here, indicating current harness model, currnet
% vehicle model and current controler model

fprintf('\n     Checking the models version. \n')
fprintf(' Please, follow the procedure Validation-> Comitting for colaborative development\n')
fprintf('    * Make sure the entire model works before comitting\n')
fprintf('    * Update the models version (inside simulink) when comitting an important release\n')

fprintf('\n          Model        ¦   Version  \n')
fprintf('======================================\n')
block_metadat = Simulink.MDLInfo('DBX_control_harness');
fprintf('  %s  ¦   %s  \n',block_metadat.BlockDiagramName,block_metadat.ModelVersion)
block_metadat = Simulink.MDLInfo('DBX_model_all');
fprintf('  %s        ¦   %s  \n',block_metadat.BlockDiagramName,block_metadat.ModelVersion)
block_metadat = Simulink.MDLInfo('dbx_control_v0_06');
fprintf('  %s    ¦   %s  \n',block_metadat.BlockDiagramName,block_metadat.ModelVersion)


%% 7. Open my dear Harness
fprintf(' \n  Starting the control design Harness')

open DBX_control_harness.slx
