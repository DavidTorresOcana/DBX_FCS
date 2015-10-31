SetupComplete;
Vx=-2*v_i0:1:2*v_i0;
Vz=-4*v_i0:1:4*v_i0;


for i=1:size(Vx,2)
    for j=1:size(Vz,2)
        FuncionAB = @(v_i) 0.745*v_i/v_i0* sqrt( (Vx(i)/v_i0)^2 + 0.447^2*(Vz(j)/v_i0)^2+(Vz(j)/v_i0+v_i/v_i0 )^2    ) -1;
        v_i(i,j) = fsolve(@(v_i) FuncionAB(v_i),v_i0);
    end
end

[X,Y]=meshgrid(Vx,Vz);
surf(X,Y,v_i')

v_i=v_i';
size(Y,1)*size(Y,2)