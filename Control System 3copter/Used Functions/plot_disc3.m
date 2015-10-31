function plot_disc3(DCM,r_0,eta,gamma)
persistent h_surf2 h_quiver

cg=cos(gamma);
sg=sin(gamma);
ce=cos(eta);
se=sin(eta);

T2=DCM*[ce,0,-se;
    se*sg,cg,ce*sg;
    se*cg,-sg,ce*cg];

n=T2*[0,0,-1]';
r_v=T2*[1,0,0]';


X_0=r_0(1);
Y_0=r_0(2);
Z_0=r_0(3);

AZ_propr=0.02;

radius = linspace(0,0.17,2); 
theta = (pi/180)*[0:5:360]; 
[R,T] = meshgrid(radius,theta); 

X = R.*cos(T); 
Y = R.*sin(T);

for i=1:size(R,1)
    for j=1:size(R,2)
        r_v_t= T2*[X(i,j);Y(i,j);0];
        X1(i,j) = r_v_t(1)+X_0;
        Y1(i,j)=r_v_t(2)+Y_0;
        Z1(i,j)=r_v_t(3) +Z_0;
    end
end
C(:,:,1)=zeros(size(Z1));
C(:,:,2)=ones(size(Z1));
C(:,:,3)=zeros(size(Z1));

if isempty(ishandle(h_surf2))==1 || ishandle(h_surf2)==0 %%&& isvalid(h_surf2)==0
    h_surf2=surf(X1,-Y1,-Z1,C,'EdgeAlpha',0);
else
    set(h_surf2,'XData',X1,'YData',-Y1,'ZData',-Z1 );
end

n=0.2*n;
if isempty(ishandle(h_quiver))==1 || ishandle(h_quiver)==0 %%&& isvalid(h_quiver)
    h_quiver = quiver3(X_0,-Y_0,-Z_0,n(1),-n(2),-n(3),'r','LineWidth',3,'MaxHeadSize',0.8);
else
    set(h_quiver,'XData',X_0,'YData',-Y_0,'ZData',-Z_0,'UData',n(1),'VData',-n(2),'WData',-n(3) );
end
% % for i=1:size(R,1)
% %     for j=1:size(R,2)
% %         r_v_t= T1*[X(i,j);Y(i,j);Z_0+AZ_propr];
% %         X2(i,j) = r_v_t(1);
% %         Y2(i,j)=r_v_t(2);
% %         Z2(i,j)= r_v_t(3);
% %     end
% % end
% % Z2
% % hold on
% % surf(X2,Y2,Z2) %Plot the sound pressure surface
% % 
% % surf([X1(:,1),X2(:,1)],[Y1(:,1),Y2(:,1)], [Z1(:,2),Z2(:,2)])
end