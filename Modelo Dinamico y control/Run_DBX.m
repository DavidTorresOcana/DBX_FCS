%Run the model of the 3copter
clear all
close all
clc
% global 
addpath(genpath('Used Functions'))
T_sim  = 0.01; % Freq simulacion
T_ctrl = 0.01;  % Freq FCS
load('Model_init_cond_Bus.mat')
load('Model_output_Bus.mat')
%% Load data
SetupComplete;
close all

% Airport
latitude=40.463650;
longitude=-3.554389;
airport_alt = 587.5;

% latitude=0.463650;
% longitude=-0.554389;

close all
% return
%% CA settings
epsilon=0.01; % Perturbation size for CA gradient computation

% return
%% Ruido y caracterizacion sensores
Sensor_params;
%% Calibracion servos y superficies moviles

Servos_calib;
%% FCS params
% FCS_fw_params;

FCS_VTOL_params;

%% Initialization
% FW_init;

VTOL_init;
%% Init motores 
% Retrieve real model trim values: Hover
load('TO_curve_raw.mat')
p0=rand;p1=rand;p2=rand;p3=rand;
Cost_TO(throtle,Omega,[p0,p1,p2,p3]);
p_good = minimize(  @(p) Cost_TO(throtle,Omega,p), [p0,p1,p2,p3] );
fitresult_TO = @(x) p_good(1)+p_good(2)*x+p_good(3)*x.^2+p_good(4)*x.^3;

% Hover point for trim
Omega_0(1)=fitresult_TO(Ref_volt*tau_1_0);
Omega_0(2)=fitresult_TO(Ref_volt*tau_2_0);
Omega_0(3)=fitresult_TO(Ref_volt*tau_3_0);
Initial_Omegas = max(0,Omega_0);

plot(throtle,Omega,'r*')
hold on
x= 2:0.1:36;
plot(x,fitresult_TO(x))
xlabel('Throtle');ylabel('omega (rads/s)')
legend(' Data','Fitted')
pause(0.1)
close all
clear x y z

% Find Torques hover
load('TTO_raw_data.mat')

p0=530;p1=-450;p2=0.6;
Cost_TTO(throtle,Mom,Omega,[p0,p1,p2]);
options = optimset('TolFun', 1e-8, 'TolX', 1e-8,'MaxFunEvals',9000000);
[p_good_TTO,fcost] = minimize(  @(p) Cost_TTO(throtle(throtle<=36),Mom(throtle<=36),Omega(throtle<=36),p), [p0,p1,p2],[],[],[],[],[],[],[],options );
fitresult_TTO = @(x,y) max(  (p_good_TTO(1).*log((x).*atan2(x,y))+p_good_TTO(2)).*(-y.^2+p_good_TTO(3))  ,  0) +eps;

plot3(throtle,Mom,Omega,'b.','Markersize',20)
hold on
[x,y]= meshgrid(2:0.1:36,0.001:0.05:3);

for i=1:size(x,1)
    for j=1:size(x,2)
        z(i,j)=fitresult_TTO(x(i,j),y(i,j));
    end
end
surf(x,y,z)
grid


X=minimize( @(X) (fitresult_TTO(Ref_volt*tau_1_0,X) -Omega_0(1))^2,0.154,[],[],[],[],0,1,[]);
Torque_0(1)=X;
plot3(Ref_volt*tau_1_0,Torque_0(1),Omega_0(1),'r.','Markersize',20)
X=minimize( @(X) (fitresult_TTO(Ref_volt*tau_2_0,X) -Omega_0(2))^2,0.154,[],[],[],[],0,1,[]);
Torque_0(2)=X;
plot3(Ref_volt*tau_2_0,Torque_0(2),Omega_0(2),'r.','Markersize',20)
X=minimize( @(X) (fitresult_TTO(Ref_volt*tau_3_0,X) -Omega_0(3))^2,0.154,[],[],[],[],0,1,[]);
Torque_0(3)=X;
plot3(Ref_volt*tau_3_0,Torque_0(2),Omega_0(3),'r.','Markersize',20)

Initial_Torques= Torque_0;

xlabel('Throtle');ylabel('Mom');zlabel('omega')
legend(' Data','Fitted','Mot 1','Mot 2','Mot 3')
pause(0.1)
close all
% 
% return
%% Trimming by  Optimization
% % options=optimset('Display','iter','LargeScale','off','TolFun',10e-9,'TolX',10e-11,'MaxFunEvals',6000,'MaxIter',6000);
% % 
% % [X,fval]= fminunc( @(X) TrimCostFunction(X), 100*[throtle_1,throtle_23,eta_23] )
% % 
% % throtle_1=X(1)/100;
% % throtle_23=X(2)/100;
% % eta_23=X(3)/100;
% % 
% % Cost = TrimCostFunction(100*[throtle_1,throtle_23,eta_23])


%% Limits of the vehicle dynamics
% Accelerations: Generate at least 1g vertical

Max_Omega= fitresult_TO(Ref_volt);
Max_Thrust = rho*pi*R^2*(Max_Omega*R)^2*0.015; % Aprox Conservative

A_z_max = Max_Thrust*3/m;

A_l_max_x = sqrt( (Max_Thrust*2/m)^2  -  (g*2/3)^2  );



