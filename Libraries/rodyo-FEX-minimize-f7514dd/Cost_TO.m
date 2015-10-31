function J=Cost_TO(x,Omega,p)
J=0;
for i=1:max(size(Omega))
    if isnan(Omega(i))==0
    J = J +( Omega(i) - (   p(1)+p(2)*x(i)+p(3)*x(i)^2+p(4)*x(i)^3 )   ).^2 ;
    end
end

end