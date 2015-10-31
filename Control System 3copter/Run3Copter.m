%Run the model of the 3copter
clear all
close all
clc
global throtle_1 throtle_23 eta_23
addpath(genpath('Used Functions'))
T_sim=0.01;
%% Load data
SetupComplete;

% Airport
latitude=52.0733;
longitude=0.6278;

close all
% return

%% Find trim point
Alt_0 =input(' Give the initial altitude (m): ');
% Cost evaluation: 1 time
throtle_23= 0.745; % Those are suposed to be the trimed state ones
eta_23 = 0;
eta_1 =deg2rad(-2);
throtle_1 = throtle_23/cos(eta_1);
% Trim_Cost = TrimCostFunction(100*[throtle_1,throtle_23,eta_23])

%% CA settings

epsilon=0.01; % Perturbation size for CA gradient computation

% return
%% Trim by  Optimization
% % options=optimset('Display','iter','LargeScale','off','TolFun',10e-9,'TolX',10e-11,'MaxFunEvals',6000,'MaxIter',6000);
% % 
% % [X,fval]= fminunc( @(X) TrimCostFunction(X), 100*[throtle_1,throtle_23,eta_23] )
% % 
% % throtle_1=X(1)/100;
% % throtle_23=X(2)/100;
% % eta_23=X(3)/100;
% % 
% % Cost = TrimCostFunction(100*[throtle_1,throtle_23,eta_23])

%% Retrieve real model trim values: Hover
load('TO_curve_raw.mat')
p0=rand;p1=rand;p2=rand;p3=rand;
Cost_TO(throtle,Omega,[p0,p1,p2,p3]);
p_good = minimize(  @(p) Cost_TO(throtle,Omega,p), [p0,p1,p2,p3] );
fitresult_TO = @(x) p_good(1)+p_good(2)*x+p_good(3)*x.^2+p_good(4)*x.^3;

% Hover point for trim
Omega_hover(1)=fitresult_TO(Ref_volt*throtle_1);
Omega_hover(2)=fitresult_TO(Ref_volt*throtle_23);
Omega_hover(3)=fitresult_TO(Ref_volt*throtle_23);
Initial_Omegas =Omega_hover;

plot(throtle,Omega,'r*')
hold on
x= 2:0.1:20;
plot(x,fitresult_TO(x))
xlabel('Throtle');ylabel('omega')
legend(' Data','Fitted')
pause
close all
clear x y z

% Find Torques hover
load('TTO_raw_data.mat')

p0=530;p1=-450;p2=0.6;
Cost_TTO(throtle,Mom,Omega,[p0,p1,p2]);
options = optimset('TolFun', 1e-8, 'TolX', 1e-8,'MaxFunEvals',900000);
[p_good_TTO,fcost] = minimize(  @(p) Cost_TTO(throtle(throtle<=18),Mom(throtle<=18),Omega(throtle<=18),p), [p0,p1,p2],[],[],[],[],[],[],[],options );
fitresult_TTO = @(x,y) max(  (p_good_TTO(1).*log((x).*atan2(x,y))+p_good_TTO(2)).*(-y.^2+p_good_TTO(3))  ,  0) +eps;

plot3(throtle,Mom,Omega,'b.','Markersize',20)
hold on
[x,y]= meshgrid(2:0.1:20,0.001:0.05:1);

for i=1:size(x,1)
    for j=1:size(x,2)
        z(i,j)=fitresult_TTO(x(i,j),y(i,j));
    end
end
surf(x,y,z)
grid


X=minimize( @(X) (fitresult_TTO(Ref_volt*throtle_1,X) -Omega_hover(1))^2,0.154,[],[],[],[],0,1,[]);
Torque_hover(1)=X;
plot3(Ref_volt*throtle_1,Torque_hover(1),Omega_hover(1),'r.','Markersize',20)
X=minimize( @(X) (fitresult_TTO(Ref_volt*throtle_23,X) -Omega_hover(2))^2,0.154,[],[],[],[],0,1,[]);
Torque_hover(2)=X;
plot3(Ref_volt*throtle_23,Torque_hover(2),Omega_hover(2),'r.','Markersize',20)
X=minimize( @(X) (fitresult_TTO(Ref_volt*throtle_23,X) -Omega_hover(3))^2,0.154,[],[],[],[],0,1,[]);
Torque_hover(3)=X;
plot3(Ref_volt*throtle_23,Torque_hover(2),Omega_hover(3),'r.','Markersize',20)

Initial_Torques= Torque_hover;

xlabel('Throtle');ylabel('Mom');ylabel('omega')
legend(' Data','Fitted','Hover 1','Hover 2')
pause
close all


%% Limits of the vehicle dynamics
% Accelerations: Generate at least 1g vertical

Max_Omega= fitresult_TO(Ref_volt);
Max_Thrust = rho*pi*R^2*(Max_Omega*R)^2*0.009; % Aprox Conservative

A_z_max = Max_Thrust*3/m;

A_l_max_x = sqrt( (Max_Thrust*3/m)^2  -  g^2  );
A_l_max_y = m*g*sind(15);



