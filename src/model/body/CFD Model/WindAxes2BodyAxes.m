function [ V_Fb ] = WindAxes2BodyAxes( V_Fw,alpha, beta )
% alpha and beta in rads!

if size(V_Fw,2)>size(V_Fw,1)
    V_Fw=V_Fw';
end
T = [cos(beta),sin(beta),0;-sin(beta),cos(beta),0;0,0,1]*[cos(alpha),0,sin(alpha);0,1,0;-sin(alpha),0,cos(alpha)];


V_Fb = T'*V_Fw;

end