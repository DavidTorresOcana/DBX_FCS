%%  Segun criterio Mecanica del vuelo clasica
%       delta_RV_S  delta_RV_A  delta_a_A
% C_l        0        0.0024     -0.1695
% C_m     -0.9917        0          0
% C_n        0        -0.0693    0.0108

%%  Segun criterio Definido por David en el modelo
%       delta_RV_S  delta_RV_A  delta_a_A
% C_l        0        0.0024?    -0.1695
% C_m      0.9917        0          0
% C_n        0        -0.0693    0.0108

B = [     0        0.0024    -0.1695;
     0.9917        0          0;
       0        -0.0693    0.0108]
   
 B_adim = B;
 B_adim(1,:) =  B_adim(1,:)/norm( B_adim(1,:));
 B_adim(2,:) =  B_adim(2,:)/norm( B_adim(2,:));
 B_adim(3,:) =  B_adim(3,:)/norm( B_adim(3,:));

 B_adim
 