%% Aqui vamos a importar los datos y crear mapas 

clc
clear all
close all
% Static [RPM,C_T,C_P]
% J Datos [J, C_T, C_P, eta]
% C_T = T/(rho.n^2.D^4)
% C_P = P/(rho.n^3.D^5)clc

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
Prop.eta_expand=NaN*ones(11,16);
Prop.V_etaexpand=NaN*ones(11,16);

Prop.J(1,1:16)=zeros(1,16);
Prop.J(2:11,1:6)= [J_test_1500.J,J_test_2096.J,J_test_2502.J,[J_test_2508.J;NaN],J_test_2991.J,J_test_3007.J];
Prop.RPM(1,1:16)=static.RPM';
Prop.RPM(2:11,1:6)= repmat([1500,2096,2502,2508,2991,3007],10,1);


Prop.RPS = Prop.RPM./60;
Prop.V = Prop.J.*Prop.RPS*D;

Prop.C_T(1,1:16)=static.C_T';
Prop.C_T(2:11,1:6)= [J_test_1500.C_T,J_test_2096.C_T,J_test_2502.C_T,[J_test_2508.C_T;NaN],...
    J_test_2991.C_T,J_test_3007.C_T];
Prop.C_P(1,1:16)=static.C_P';
Prop.C_P(2:11,1:6)= [J_test_1500.C_P,J_test_2096.C_P,J_test_2502.C_P,[J_test_2508.C_P;NaN],...
    J_test_2991.C_P,J_test_3007.C_P];
Prop.eta(2:11,1:6)= [J_test_1500.eta,J_test_2096.eta,J_test_2502.eta,[J_test_2508.eta;NaN],...
    J_test_2991.eta,J_test_3007.eta];


% Expand V, RPM, eta boundaries
V_etaexpand=[1,7,10,12,13,14,15,17,20,23,27];

for i=1:2
    Prop.V_etaexpand(:,i)=V_etaexpand;
    fit_eta=DosDEta_V(Prop.V(:,i), Prop.eta(:,i)  );
    pause
    Prop.eta_expand(1:11,i) = fit_eta(V_etaexpand);
end

Prop.V_etaexpand(:,3)=V_etaexpand;
Prop.V_etaexpand(:,4)=V_etaexpand;
fit_eta=DosDEta_V([Prop.V(:,3);Prop.V(:,4)], [Prop.eta(:,3);Prop.eta(:,3+1)]  );
pause
Prop.eta_expand(1:11,3) = fit_eta(V_etaexpand);
Prop.eta_expand(1:11,4) = fit_eta(V_etaexpand);

Prop.V_etaexpand(:,5)=V_etaexpand;
Prop.V_etaexpand(:,6)=V_etaexpand;
fit_eta=DosDEta_V([Prop.V(:,5);Prop.V(:,6)], [Prop.eta(:,5);Prop.eta(:,6)]  );
pause
Prop.eta_expand(1:11,5) = fit_eta(V_etaexpand);
Prop.eta_expand(1:11,6) = fit_eta(V_etaexpand);

close all

%% Plots
figure
plot3(Prop.V,Prop.RPS,Prop.C_T,'*')
xlabel('V(m/s)')
ylabel('RPS')
zlabel('C_T')
grid

figure
plot3(Prop.V,Prop.RPS,Prop.C_P,'*')
xlabel('V(m/s)')
ylabel('RPS')
zlabel('C_P')
grid

figure
plot3(Prop.V,Prop.RPS,Prop.eta,'*')
xlabel('V(m/s)')
ylabel('RPS')
zlabel('eta(%)')
grid

figure
plot3(Prop.V_etaexpand(Prop.eta_expand>-10),Prop.RPS(Prop.eta_expand>-10),Prop.eta_expand(Prop.eta_expand>-10),'*')
xlabel('V(m/s)')
ylabel('RPS')
zlabel('eta expand(%)')
grid

pause
close all
%% Ajuste polinomico

% RPS=Prop.RPS;
% C_P= Prop.C_P;
% J=Prop.J;
% V=Prop.V;
% C_T=Prop.C_T;
% eta=Prop.eta;
% V_etaexpand=Prop.V_etaexpand
% etaexpand=Prop.eta_expand;
% etaexpand(etaexpand<-50)=NaN;

% Fittings
fit_CP=Fit_CP(Prop.RPS, Prop.V, Prop.C_P);
fit_CT=Fit_CT(Prop.RPS, Prop.V, Prop.C_T);
fit_eta_expand=Fit_eta_expand(Prop.RPS(Prop.eta_expand>-10), Prop.V_etaexpand(Prop.eta_expand>-10), Prop.eta_expand(Prop.eta_expand>-10)  );
fit_eta=Fit_eta(Prop.RPS(Prop.eta>0), Prop.V(Prop.eta>0), Prop.eta(Prop.eta>0)  );


% close all
[RPS,V]=meshgrid(20:1:80,0:0.5:25);

figure
grid
surf(RPS,V,fit_CT(RPS,V) )
ylabel('V(m/s)')
xlabel('RPS')
zlabel('C_T')


figure
grid
surf(RPS,V,fit_CP(RPS,V))
ylabel('V(m/s)')
xlabel('RPS')
zlabel('C_P')


figure

surf(V,RPS,fit_eta(RPS,V))
hold on
plot3(Prop.V,Prop.RPS,Prop.eta,'*')
xlabel('V(m/s)')
ylabel('RPS')
zlabel('eta(%)')
axis([min(min(V)) max(max(V)) min(min(RPS)) max(max(RPS)) 0 1])

figure
grid
surf(RPS,V,fit_eta_expand(RPS,V))
ylabel('V(m/s)')
xlabel('RPS')
zlabel('eta(%)')
axis([min(min(RPS)) max(max(RPS)) min(min(V)) max(max(V)) 0 1])
    
pause
close all


%%
for i=1:size(RPS,1)
    for j=1:size(RPS,2)
        C_P(i,j) = fit_CP(RPS(i,j),V(i,j));
        eta(i,j) = fit_eta(RPS(i,j),V(i,j));
        if C_P(i,j)<0
            C_P(i,j)=NaN;
        end
        if eta(i,j)<0
            eta(i,j)=NaN;
        end
    end
end

figure;
[C,h] =contour(V,fit_CP(RPS,V),fit_eta(RPS,V),[0,0.2,0.5,0.7,0.9,1]);
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
colorbar
axis square;
xlabel('V ');
ylabel('C_P ');


[RPS,V]=meshgrid(20:1:70,0:0.5:25);

hold on
contour(V,fit_CP(RPS,V),RPS,'k');

return
%% C_P and eta map
fit_eta_C_P=Fit_eta_C_P( Prop.V,  Prop.C_P,  Prop.eta)


[V,C_P]=meshgrid(0:1:25,0:0.005:0.07);

figure;
[C,h] =contour(V,C_P,fit_eta_C_P(V,C_P),[0,0.2,0.5,0.7,0.9,1]);
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
colorbar
axis square;
xlabel('V ');
ylabel('C_P ');


[RPS,V]=meshgrid(20:1:70,0:0.5:25);

hold on
contour(V,fit_CP(RPS,V),RPS,'k');

