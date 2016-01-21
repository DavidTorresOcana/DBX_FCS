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