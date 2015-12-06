%% De acuerdo al modelo aerodinamico definido en 
% Dropbox\DroneBoX\Ingeniería\03. Software y sistemas\SW\Modelado y FCS\Modelado\Modelo aerodinamico V2.docx
%% Import the data
[~, ~, raw] = xlsread('.\Datos Aero DBX v2.xlsx','Raw Data','A2:M104');

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
Alfa = data(:,1);
Beta = data(:,2);
delta_ale = data(:,3);
delta_elev = data(:,4);
delta_rud = data(:,5);
C_x = data(:,6);
C_y = data(:,7);
C_z = data(:,8);
C_l_raw = data(:,9);
C_m_raw =  data(:,10);
C_n_raw = data(:,11);
C_L = data(:,12);
C_D = data(:,13);
%% Clear temporary variables
clearvars data raw raw0_0 raw0_1 RRR;

%% Generar unicos valores de angulos
delta_elev_unique = unique(delta_elev);
Alpha_unique = unique(Alfa);
Beta_unique = unique(Beta);
delta_rud_unique = unique(delta_rud);
delta_ale_unique = unique(delta_ale);

%% Generar C_X(alpha,beta)
DBX_aero.C_X = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        try
            DBX_aero.C_X(i,j) = C_x(idx);
        catch
            % %                 idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-2)).*(Beta==Beta_unique(j)) );
            % %                 PrevPrev = C_x(idx);
            % %                 idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-1)).*(Beta==Beta_unique(j)) );
            % %                 Prev = C_x(idx);
            % %                 slope=(Prev-PrevPrev)/(Alpha_unique(k-1)-Alpha_unique(k-2));
            % %                 C_X(k,j,i) = C_x(idx)+slope*(Alpha_unique(k)-Alpha_unique(k-1));
        end
        
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_X(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_X')
title(['\delta_{elev} = ',num2str(0),'deg'])

% return
% pause
%% Generar C_X_delta_elev(alpha,delta_elev)
DBX_aero.C_X_delta_elev = NaN*ones(size(Alpha_unique,1),size(delta_elev_unique,1) );
figure
hold on
grid
xlabel('Alpha')
ylabel('C_X_delta_e')
title('C_X_delta_e vs, alfa vs. delta_elev')

for j=1:size(delta_elev_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(j)).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        idx_zero = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        try
            DBX_aero.C_X_delta_elev(i,j) = C_x(idx) - C_x(idx_zero);  % Este coeficiente es un Delta_coef
        end
    end
    legend_str{j} = ['delta_e ', num2str(delta_elev_unique(j))];
    plot(Alpha_unique,DBX_aero.C_X_delta_elev(:,j))
end
legend(legend_str)
% return
%% Generar C_Y(alpha,beta)
close all
DBX_aero.C_Y = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        DBX_aero.C_Y(i,j) = C_y(idx);
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_Y(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_Y')

%% Generar C_Y_delta_rud
C_Y_delta_rud = NaN*ones(size(delta_rud_unique,1),1 );
figure
hold on
xlabel('delta_rud_unique')
ylabel('C_Y_delta_rud')
title('C_Y_delta_rud vs delta_rud_unique')

for j=1:size(delta_rud_unique,1)
    idx = logical(  (delta_ale==0).*(delta_rud==delta_rud_unique(j)).*(delta_elev==0).*(Alfa==0).*(Beta==0) );
    try
        C_Y_delta_rud(j) = C_y(idx);  
    end
    
end
plot(delta_rud_unique,C_Y_delta_rud)

% Cojer SOLO el caso de 5deg. El caso de 10deg ESTA MAL % FIXME
idx = logical(  (delta_rud==-5) );
DBX_aero.C_Y_delta_rud = C_y(idx)/deg2rad(delta_rud(idx)); % Para que este acorde con el delta_rudder del criterio tradicional

% return
% pause
%% Generar C_Z(alpha,beta)
close all
DBX_aero.C_Z = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        try
            DBX_aero.C_Z(i,j) = C_z(idx);      
        end
        
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_Z(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_Z')
title(['\delta_{elev} = ',num2str(0),'deg'])

% return
pause
%% Generar C_Z_delta_elev(alpha,delta_elev)
DBX_aero.C_Z_delta_elev = NaN*ones(size(Alpha_unique,1),size(delta_elev_unique,1) );
figure
hold on
grid
xlabel('Alpha')
ylabel('C_Z_delta_e')
title('C_Z_delta_e vs, alfa vs. delta_elev')

for j=1:size(delta_elev_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(j)).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        idx_zero = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        try
            DBX_aero.C_Z_delta_elev(i,j) = C_z(idx) - C_z(idx_zero);  % Este coeficiente es un Delta_coef
        end
    end
    legend_str{j} = ['delta_e ', num2str(delta_elev_unique(j))];
    plot(Alpha_unique,DBX_aero.C_Z_delta_elev(:,j))
end
legend(legend_str)
return







%% Generar C_l(alpha,beta,deltas=0)
close all
C_l = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );

for j=1:size(Beta_unique,1)
    for k=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(k)).*(Beta==Beta_unique(j)) );
%         if sum(C_x(idx))
            C_l(k,j) = C_l_raw(idx);
%         end
    end
    
end
figure
surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_l(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_l')
% C_l_delta_rv_Asim
delta_rud_unique = unique(delta_rud);
idx = logical(  (delta_rud==delta_rud_unique(2)) );
C_l_delta_rv_Asim = C_l_raw(idx)/deg2rad(delta_rud(idx));

% C_l_delta_a_Asim
idx = logical(  (delta_ale==delta_ale_unique(2)) );

C_l_delta_a_Asim = C_l_raw(idx)/deg2rad(delta_ale(idx));


pause

%% Generar C_m(alpha,delta_elev=delta_rv_sim,deltas=0)
close all
C_m = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1),size(delta_elev_unique,1) );

for i=1:size(delta_elev_unique,1)
    idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)) );
    for j=1:size(Beta_unique,1)
        for k=1:size(Alpha_unique,1)
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k)).*(Beta==Beta_unique(j)) );
            try 
                C_m(k,j,i) = C_m_raw(idx);
            catch
                idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-2)).*(Beta==Beta_unique(j)) );
                PrevPrev = C_m_raw(idx);
                idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-1)).*(Beta==Beta_unique(j)) );
                Prev = C_m_raw(idx);
                slope=(Prev-PrevPrev)/(Alpha_unique(k-1)-Alpha_unique(k-2));
                
                C_m(k,j,i) = C_m_raw(idx)+slope*(Alpha_unique(k)-Alpha_unique(k-1));
            end
        end
    end
    figure
    surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_m(:,:,i))
    grid
    xlabel('Alpha')
    ylabel('Beta')
    zlabel('C_m')
    title(['\delta_{elev} = ',num2str(delta_elev_unique(i)),'deg'])
end


% C_m_delta_ele efectivo
C_m_delta_ele_MAT = (C_m(:,:,3)-C_m(:,:,1))./deg2rad(delta_elev_unique(3)-delta_elev_unique(1)),
surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_m_delta_ele_MAT)

C_m_delta_rv_sim = mean(C_m_delta_ele_MAT(1:end-1,2));

pause

%% Generar C_n(alpha,beta,deltas=0)
close all
C_n = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );

for j=1:size(Beta_unique,1)
    for k=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(k)).*(Beta==Beta_unique(j)) );
%         if sum(C_n_raw(idx))
            C_n(k,j) = C_n_raw(idx);
%         end
    end
end
figure
surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_n(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_n')
% C_n_delta_rv_Asim
idx = logical(  (delta_rud==delta_rud_unique(2)) );
C_n_delta_rv_Asim = C_n_raw(idx)/deg2rad(delta_rud(idx));

% C_l_delta_a_Asim
idx = logical(  (delta_ale==delta_ale_unique(2)) );

C_n_delta_a_Asim = C_n_raw(idx)/deg2rad(delta_ale(idx));


pause

%% Pasar las deflexones a rads!
delta_elev_unique_rad   = deg2rad(delta_elev_unique);
Alpha_unique_rad        = deg2rad(Alpha_unique);
Beta_unique_rad         = deg2rad(Beta_unique);
delta_rud_unique_rad    = deg2rad(delta_rud_unique);
delta_ale_unique_rad    = deg2rad(delta_ale_unique);


%% Definir los coeficientes de amortiguamiento

Importar_coef_amortiguacion

% C_Lift_q
C_Lift_q = 10.9; 
% C_D_q
C_D_q = 0.0336; 


% C_Y_r
C_Y_r = 0.5219;
% C_Y_p
C_Y_p = -0.0991;


% C_l_p
C_l_p = -0.8333;
% C_l_r
C_l_r = 0.0347;

% C_m_q
C_m_q = -45.7828;


% C_n_p
C_n_p = -0.0066;
% C_n_r
C_n_r = -0.1827;
