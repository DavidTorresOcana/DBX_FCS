function [ V_Fw ] = BodyAxes2WindAxes( V_Fb,alpha, beta )
% alpha and beta in rads!

if size(V_Fb,2)>size(V_Fb,1)
    V_Fb=V_Fb';
end
T = [cos(beta),sin(beta),0;-sin(beta),cos(beta),0;0,0,1]*[cos(alpha),0,sin(alpha);0,1,0;-sin(alpha),0,cos(alpha)];


V_Fw = T*V_Fb;

end