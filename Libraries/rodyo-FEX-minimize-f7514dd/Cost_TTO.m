function J=Cost_TTO(x,y,Omega,p)
J=0;
for i=1:max(size(Omega))
    if isnan(Omega(i))==0
        J = J +( Omega(i) - ( max(  (p(1)*log((x(i))*atan2(x(i),y(i)))+p(2))*(-y(i)^2+p(3)) ,  0) +eps  )  ).^2  ;
    end
end

end