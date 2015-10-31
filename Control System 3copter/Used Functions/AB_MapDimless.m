SetupComplete;
Vx_adim=-2:0.1:2;
Vz_adim=-4:0.1:4;


for i=1:size(Vx_adim,2)
    for j=1:size(Vz_adim,2)
        FuncionAB = @(v_i_adim) 0.745*v_i_adim* sqrt( (Vx_adim(i))^2 + 0.447^2*(Vz_adim(j))^2+(Vz_adim(j)+v_i_adim )^2    ) -1;
        v_i_adim(i,j) = fsolve(@(v_i_adim) FuncionAB(v_i_adim),1);
    end
end
[X,Y]=meshgrid(Vx_adim,Vz_adim);
surf(X,Y,v_i_adim')

size(Y,1)*size(Y,2)