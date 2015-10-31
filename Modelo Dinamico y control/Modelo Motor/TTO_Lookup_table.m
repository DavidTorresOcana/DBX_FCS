%% 
clear all 
clc
close all

load('TTO_raw_data.mat')
% % 
% % plot3(throtle,Mom,Omega,'*')
%% Interpolate
fitt=TTO_data_fitV2(throtle(throtle<=33), Mom(throtle<=33), Omega(throtle<=33))

% % % % Manual interpolation
% % % a=0;
% % % b=-0;
% % % c=0.0;
% % % Cost_fit(throtle(throtle<=16),Mom(throtle<=16),Omega(throtle<=16),a,b,c) % Throle less than 16 (Saturation)
% % % 
% % % XX = fminunc( @(XX) Cost_fit(throtle(throtle<=16),Mom(throtle<=16),Omega(throtle<=16),XX(1),XX(2),XX(3)) , [a,b,c])
% % % a=XX(1);
% % % b=XX(2);
% % % c=XX(3);
% return
%% Extrapolate
Throtle_TTO=0:0.5:35;
Torque_TTO=-3:0.2:3;
for i=1:size(Throtle_TTO,2)
    for j=1:size(Torque_TTO,2)
        if Torque_TTO(j)>=0
            Omega_TTO(i,j) = max(0, min( fitt(Throtle_TTO(i),Torque_TTO(j)),fitt(33,Torque_TTO(j))  ) );
        else
            Omega_TTO(i,j) = 2*max(0, min( fitt(Throtle_TTO(i),0),fitt(33,0)  ) ) - max(0, min( fitt(Throtle_TTO(i),-Torque_TTO(j)),fitt(33,-Torque_TTO(j))  ) );
            Omega_TTO(i,j) = max(0,Omega_TTO(i,j));
        end
        
    end
end

% max(0, min((a*log((x)*atan2(x,y))+b)/(y+c),(a*log((x)*atan2(x,y))+b)/(y+c)   ) )
% 
% C(:,:,1)=ones(size(Z));
% C(:,:,2)=zeros(size(Z));
% C(:,:,3)=zeros(size(Z));

figure
h=surf(repmat(Throtle_TTO',1,size(Torque_TTO,2)),repmat(Torque_TTO,size(Throtle_TTO,2),1),Omega_TTO)
hold on
plot3(throtle,Mom,Omega,'o','MarkerEdgeColor','w','MarkerFaceColor',[0,0,1],...
    'MarkerSize',5)
xlabel(' Equivalent Throtle (V)')
ylabel(' Torque (N.m)')
zlabel('Omega (rad/s)')

% % figure
% % h=surf(Throtle_TTO,Torque_TTO,Torque_TTO.*Omega_TTO)
% % hold on
% % plot3(throtle,Mom,Omega,'o','MarkerEdgeColor','w','MarkerFaceColor',[0,0,1],...
% %                 'MarkerSize',5)
% %             xlabel(' Equivalent Throtle (V)')
% % ylabel(' Torque (N.m)')
% % zlabel('Power (W)')
% % title('Power curve')


figure
hold on
for i=1:size(Throtle_TTO,2)
    plot(Torque_TTO,Omega_TTO(i,:))
end

return
%% Ideal surface
X=repmat(min(throtle):0.1:max(throtle),size(min(Mom):0.01:max(Mom),2),1);
Y=repmat(min(Mom):0.01:max(Mom),size(min(throtle):0.1:max(throtle),2),1)';
Z=228*2*pi/60.*X;


C(:,:,1)=ones(size(Z));
C(:,:,2)=zeros(size(Z));
C(:,:,3)=zeros(size(Z));

h=surf(X,Y,Z,C)
set(h,'FaceAlpha',0.5)

legend(' Real curve', 'Test data','Ideal curve')


%% 