function [ V_Fw ] = BodyAxes2WindAxes_AoA( V_Fb,alpha )
% alpha and beta in rads!

if size(V_Fb,2)>size(V_Fb,1)
    V_Fb=V_Fb';
end
T = [cos(alpha),0,sin(alpha);0,1,0;-sin(alpha),0,cos(alpha)];

V_Fw = T*V_Fb;

end