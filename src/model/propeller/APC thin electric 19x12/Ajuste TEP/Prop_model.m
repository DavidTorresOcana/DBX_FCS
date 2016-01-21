%% Aqui vamos a importar los datos, crear mapas e intentar ajustar una teoria 
% para predecir performances

clc
clear all
close all
% Static [RPM,C_T,C_P]
% J Datos [J, C_T, C_P, eta]
% C_T = T/(rho.n^2.D^4)
% C_P = P/(rho.n^3.D^5)
% P=2.pi.n.Q
% n is in rps
% J=V/nD
% eta=J*C_T/C_P
rho=1.225;
D = 2*0.2413;
S=pi*(D/2)^2;

load('static.mat')
% apce19x12_2096_row = importfile('apce_19x12_jb1080_2096.txt', 2, 11);
% J_test_2096.J=apce19x12_2096_row(:,1);
% J_test_2096.C_T=apce19x12_2096_row(:,2);
% J_test_2096.C_P=apce19x12_2096_row(:,3);
% J_test_2096.eta=apce19x12_2096_row(:,4);
load('J_test_1500.mat')
load('J_test_2096.mat')
load('J_test_2502.mat')
load('J_test_2508.mat')
load('J_test_2991.mat')
load('J_test_3007.mat')

% Format data [J,RPM]
Prop.J=NaN*ones(11,16);
Prop.RPM=NaN*ones(11,16);
Prop.C_T=NaN*ones(11,16);
Prop.eta=NaN*ones(11,16);

Prop.J(1,1:16)=zeros(1,16);
Prop.J(2:11,1:6)= [J_test_1500.J,J_test_2096.J,J_test_2502.J,[J_test_2508.J;NaN],J_test_2991.J,J_test_3007.J];
Prop.RPM(1,1:16)=static.RPM';
Prop.RPM(2:11,1:6)= repmat([1500,2096,2502,2508,2991,3007],10,1);
Prop.RPS = Prop.RPM./60;
Prop.C_T(1,1:16)=static.C_T';
Prop.C_T(2:11,1:6)= [J_test_1500.C_T,J_test_2096.C_T,J_test_2502.C_T,[J_test_2508.C_T;NaN],...
    J_test_2991.C_T,J_test_3007.C_T];
Prop.C_P(1,1:16)=static.C_P';
Prop.C_P(2:11,1:6)= [J_test_1500.C_P,J_test_2096.C_P,J_test_2502.C_P,[J_test_2508.C_P;NaN],...
    J_test_2991.C_P,J_test_3007.C_P];
Prop.eta(2:11,1:6)= [J_test_1500.eta,J_test_2096.eta,J_test_2502.eta,[J_test_2508.eta;NaN],...
    J_test_2991.eta,J_test_3007.eta];
%% Plots
figure
plot3(Prop.J,Prop.RPS,Prop.C_T,'*')
xlabel('J')
ylabel('RPS')
zlabel('C_T')
grid

figure
plot3(Prop.J,Prop.RPS,Prop.C_P,'*')
xlabel('J')
ylabel('RPS')
zlabel('C_P')
grid

figure
plot3(Prop.J,Prop.RPS,Prop.eta,'*')
xlabel('J')
ylabel('RPS')
zlabel('eta(%)')
grid
pause
close all
%% Ajuste a la TEP
% C_T = sigma*a/4*(theta_0*2/3+theta_1/2-lambda)
% C_Q = C_P = sigma*a/4*(theta_0*2/3+theta_1/2-lambda)*lambda + c_d_0*sigma/4
PropTEP.RadPS = Prop.RPM*2*pi/60;
PropTEP.V_z = Prop.J.*Prop.RPS*D;
PropTEP.T_test = Prop.C_T.*((rho*Prop.RPS.^2).*D^4); % Newtons!
PropTEP.C_T_test = PropTEP.T_test./(rho*S*(PropTEP.RadPS*D/2).^2);
PropTEP.C_Q_test = Prop.C_P.*((Prop.RPS.^2).*D^5)./(2*pi*S*(D/2)*(PropTEP.RadPS*D/2).^2);

% Vel inducida pto fijo
% Depende de la velocidad angular de la helice
PropTEP.v_i_0=sqrt(PropTEP.T_test(1,:)./(2*rho*S));
v_i_0_Omega = Fit_v_i_0(PropTEP.RadPS(1,:), PropTEP.v_i_0);
for i=1:size(PropTEP.RadPS,1)
    for j=1:size(PropTEP.RadPS,2) % Mapa AB de vel inducidas: Rama descendente V_z>0
        v_i_0=v_i_0_Omega(PropTEP.RadPS(i,j));
        PropTEP.V_i(i,j) =v_i_0*1/2*(-PropTEP.V_z(i,j)/v_i_0 +sqrt((PropTEP.V_z(i,j)/v_i_0)^2+4));
    end
end
% plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP.V_i,'*');

PropTEP.lambda = (PropTEP.V_i + PropTEP.V_z)./(D/2*PropTEP.RadPS); % Mantenemos la definicion positiva de lambda como en Leishman. Diferente al Cuerva!!

% Prediciones con la TEP: Ajustar parametros y modelos dentro!!
a=6.77;
c_d_0=0.08;
Prop_props.theta_0 = 0.7608; % Equivalente
Prop_props.theta_1 = -0.6531; % Equivalente
Prop_props.c=0.02603;
Prop_props.sigma= 2*Prop_props.c/(pi*(D/2));

[PropTEP.C_T_TEP,PropTEP.C_Q_TEP] = TEP_pred(a,c_d_0,Prop_props,PropTEP.lambda);

% Ajuste
% Cost = Coste_TEP(a,c_d_0,Prop_props,PropTEP);
% X = fminsearch(@(X) Coste_TEP(X(1,1),X(2,1),Prop_props,PropTEP),[a,c_d_0]');
% a= X(1);
% c_d_0= X(2);

[PropTEP.C_T_TEP,PropTEP.C_Q_TEP] = TEP_pred(a,c_d_0,Prop_props,PropTEP.lambda);

%% Plots y comparacion

figure
h1=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP.C_T_TEP,'r*');
hold on
h2=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP.C_T_test,'b*');
xlabel('V_z')
ylabel('rad/s')
zlabel('C_T_{TEP}')
grid
legend([h1(1),h2(1)],' TEP', 'Test')

figure
h1=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP.C_Q_TEP,'r*');
hold on
h2=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP.C_Q_test,'b*');
xlabel('V_z')
ylabel('rad/s')
zlabel('C_Q_{TEP}')
grid
legend([h1(1),h2(1)],' TEP', 'Test')

% Plot contra lambda
figure
h1=plot(PropTEP.lambda,PropTEP.C_T_TEP,'r*');
hold on
h2=plot(PropTEP.lambda,PropTEP.C_T_test,'b*');
xlabel('lambda')
ylabel('C_T')
grid
legend([h1(1),h2(1)],' TEP', 'Test')
return
%% TEP modificada: a,c_d_0,  lambda_0_T,kappa_T  ,lambda_0_Q,kappa_Q
close all
[PropTEP_mod.C_T_TEP,PropTEP_mod.C_Q_TEP] = TEP_mod_pred(3.7,0.0811,0.1091,2.7446,0.0977,2.72,Prop_props,PropTEP.lambda);
Coste_TEP_mod(3.7,0.0811,0.1091,2.7446,0.0977,2.72,Prop_props,PropTEP)
% Ajuste
[X,Cost] = fminsearch(@(X) Coste_TEP_mod(X(1,1),X(2,1),X(3,1),X(4,1),X(5,1),X(6,1),Prop_props,PropTEP),[4,0.148,   0.05,5,0.0357,1.2461]')

% [ 4.0152,0.2,0.0462,4.2976,0.1155,-3.7711] Total

[PropTEP_mod.C_T_TEP,PropTEP_mod.C_Q_TEP] = TEP_mod_pred(X(1,1),X(2,1),X(3,1),X(4,1),X(5,1),X(6,1),Prop_props,PropTEP.lambda);

% [PropTEP_mod.C_T_TEP,PropTEP_mod.C_Q_TEP] = TEP_mod_pred(4,0.148,   0.05,5,0.0357,1.2461,Prop_props,PropTEP.lambda);

% Plot contra lambda

figure
h1=plot(PropTEP.lambda,PropTEP_mod.C_T_TEP,'r*');
hold on
h2=plot(PropTEP.lambda,PropTEP.C_T_test,'b*');
xlabel('lambda')
ylabel('C_T')
grid
legend([h1(1),h2(1)],' TEP mod', 'Test')
% return
figure
h1=plot(PropTEP.lambda,PropTEP_mod.C_Q_TEP,'r*');
hold on
h2=plot(PropTEP.lambda,PropTEP.C_Q_test,'b*');
xlabel('lambda')
ylabel('C_Q')
grid
legend([h1(1),h2(1)],' TEP mod', 'Test')
return

figure
h1=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP_mod.C_T_TEP,'r*');
hold on
h2=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP.C_T_test,'b*');
xlabel('V_z')
ylabel('rad/s')
zlabel('C_T_{TEPmod}')
grid
legend([h1(1),h2(1)],' TEP mod', 'Test')

figure
h1=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP_mod.C_Q_TEP,'r*');
hold on
h2=plot3(PropTEP.V_z,PropTEP.RadPS,PropTEP.C_Q_test,'b*');
xlabel('V_z')
ylabel('rad/s')
zlabel('C_Q_{TEPmd}')
grid
legend([h1(1),h2(1)],' TEP mod', 'Test')


