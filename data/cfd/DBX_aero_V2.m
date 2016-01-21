close all
%% De acuerdo al modelo aerodinamico definido en 
% Dropbox\DroneBoX\Ingeniería\03. Software y sistemas\SW\Modelado y FCS\Modelado\Modelo aerodinamico V2.docx
%% Import the data
[~, ~, raw] = xlsread('.\Datos Aero DBX v2.xlsx','Raw Data',['A2:M',num2str(size(Aero_Forc_Mom_data,2)+1)]);

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
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
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
title('C_X vs beta vs alfa')

% return
% pause
%% Generar C_X_delta_elev(alpha,delta_elev)
DBX_aero.C_X_delta_elev = NaN*ones(size(Alpha_unique,1),size(delta_elev_unique,1) );
figure
hold on
grid
xlabel('Alpha')
ylabel('C_X_{\delta}_e')
title('C_X_{\delta}_{ele} vs, alfa vs. \delta_{elev}')

for j=1:size(delta_elev_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(j)).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        idx_zero = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        try
            DBX_aero.C_X_delta_elev(i,j) = C_x(idx) - C_x(idx_zero);  % Este coeficiente es un Delta_coef
        catch
            DBX_aero.C_X_delta_elev(i,j) = 0;
        end
    end
    legend_str{j} = ['\delta_e ', num2str(delta_elev_unique(j))];
    plot(Alpha_unique,DBX_aero.C_X_delta_elev(:,j))
end
legend(legend_str)
% return
%% Generar C_Y(alpha,beta)
% close all
DBX_aero.C_Y = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
        end
        try
            DBX_aero.C_Y(i,j) = C_y(idx);
        end
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_Y(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_Y')
title('C_Y vs beta vs alfa')

%% Generar C_Y_delta_rud
C_Y_delta_rud = NaN*ones(size(delta_rud_unique,1),1 );
figure
hold on
xlabel('\delta_{rud}')
ylabel('C_Y_{\delta}_{rud}')
title('C_Y_{delta}_{rud} vs \delta_{rud}')

for j=1:size(delta_rud_unique,1)
    idx = logical(  (delta_ale==0).*(delta_rud==delta_rud_unique(j)).*(delta_elev==0).*(Alfa==0).*(Beta==0) );
    try
        C_Y_delta_rud(j) = C_y(idx);
    catch
        C_Y_delta_rud(j) = 0;
    end
    
end
plot(delta_rud_unique,C_Y_delta_rud)

% Escojer un caso
% idx = logical(  (delta_rud==delta_rud_unique) );
% DBX_aero.C_Y_delta_rud = C_y(idx)/deg2rad(delta_rud(idx));

% Hacer la media  
DBX_aero.C_Y_delta_rud = mean( C_Y_delta_rud(delta_rud_unique~=0)./deg2rad( delta_rud_unique(delta_rud_unique~=0) ) );

% return
% pause
%% Generar C_Z(alpha,beta)
% close all
DBX_aero.C_Z = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
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
title('C_Z vs beta vs alfa')

% return
% pause
%% Generar C_Z_delta_elev(alpha,delta_elev)
DBX_aero.C_Z_delta_elev = NaN*ones(size(Alpha_unique,1),size(delta_elev_unique,1) );
figure
hold on
grid
xlabel('Alpha')
ylabel('C_Z_{\delta}_e')
title('C_Z_{\delta}_e vs, alfa vs. \delta_{elev}')
for j=1:size(delta_elev_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(j)).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        idx_zero = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        try
            DBX_aero.C_Z_delta_elev(i,j) = C_z(idx) - C_z(idx_zero);  % Este coeficiente es un Delta_coef
        catch
            DBX_aero.C_Z_delta_elev(i,j) = 0;
        end
    end
    legend_str{j} = ['\delta_e ', num2str(delta_elev_unique(j))];
    plot(Alpha_unique,DBX_aero.C_Z_delta_elev(:,j))
end
legend(legend_str)
% return


%% Generar C_L(alpha,beta)
% close all
DBX_aero.C_L = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
        end
        try
            DBX_aero.C_L(i,j) = C_L(idx);      
        end
        
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_L(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_L')
title('C_L vs beta vs alfa')

% return
% pause
%% Generar C_L_delta_elev(alpha,delta_elev)
DBX_aero.C_L_delta_elev = NaN*ones(size(Alpha_unique,1),size(delta_elev_unique,1) );
figure
hold on
grid
xlabel('Alpha')
ylabel('C_L_{\delta}_e')
title('C_L_{\delta}_{ele} vs, alfa vs. \delta_{elev}')

for j=1:size(delta_elev_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(j)).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        idx_zero = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        try
            DBX_aero.C_L_delta_elev(i,j) = C_L(idx) - C_L(idx_zero);  % Este coeficiente es un Delta_coef
        catch
            DBX_aero.C_L_delta_elev(i,j) = 0;
        end
    end
    legend_str{j} = ['\delta_e ', num2str(delta_elev_unique(j))];
    plot(Alpha_unique,DBX_aero.C_L_delta_elev(:,j))
end
legend(legend_str)
% return

%% Generar C_D(alpha,beta)
% close all
DBX_aero.C_D = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
        end
        try
            DBX_aero.C_D(i,j) = C_D(idx);      
        end
        
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_D(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_D')
title('C_D vs beta vs alfa')

% return
% pause
%% Generar C_D_delta_elev(alpha,delta_elev)
DBX_aero.C_D_delta_elev = NaN*ones(size(Alpha_unique,1),size(delta_elev_unique,1) );
figure
hold on
grid
xlabel('Alpha')
ylabel('C_D_{\delta}_e')
title('C_D_{\delta}_{ele} vs, alfa vs. \delta_{elev}')

for j=1:size(delta_elev_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(j)).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        idx_zero = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        try
            DBX_aero.C_D_delta_elev(i,j) = C_D(idx) - C_D(idx_zero);  % Este coeficiente es un Delta_coef
        catch
             DBX_aero.C_D_delta_elev(i,j) = 0;
        end
    end
    legend_str{j} = ['\delta_e ', num2str(delta_elev_unique(j))];
    plot(Alpha_unique,DBX_aero.C_D_delta_elev(:,j))
end
legend(legend_str)
% return

%% Generar C_l(alpha,beta)
% close all
DBX_aero.C_l = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
        end
        try
            DBX_aero.C_l(i,j) = C_l_raw(idx);      
        end
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_l(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_l')
title('C_l vs beta vs alfa')

%% Generar C_l_delta_rud
C_l_delta_rud = NaN*ones(size(delta_rud_unique,1),1 );
figure
hold on
xlabel('delta_rud')
ylabel('C_l_{\delta}_{rud}')
title('C_l_{\delta}_{rud} vs \delta_{rud}')
for j=1:size(delta_rud_unique,1)
    idx = logical(  (delta_ale==0).*(delta_rud==delta_rud_unique(j)).*(delta_elev==0).*(Alfa==0).*(Beta==0) );
    try
        C_l_delta_rud(j) = C_l_raw(idx);  
    end
    
end
plot(delta_rud_unique,C_l_delta_rud)

% Escojer un caso
% idx = logical(  (delta_rud==-5) );
% DBX_aero.C_l_delta_rud = C_l_raw(idx)/deg2rad(delta_rud(idx)); 

% Hacer la media  
DBX_aero.C_l_delta_rud = mean( C_l_delta_rud(delta_rud_unique~=0)./deg2rad( delta_rud_unique(delta_rud_unique~=0) ) );

%% Generar C_l_delta_ale
C_l_delta_ale = NaN*ones(size(delta_ale_unique,1),1 );
figure
hold on
xlabel('\delta_{ale}')
ylabel('C_l_{\delta}_{ale}')
title('C_l_{\delta}_{ale} vs \delta_{ale}')

for j=1:size(delta_ale_unique,1)
    idx = logical(  (delta_ale==delta_ale_unique(j)).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==0) );
    try
        C_l_delta_ale(j) = C_l_raw(idx);  
    end
end
plot(delta_ale_unique,C_l_delta_ale)

% Escoger un caso
% idx = logical(  (delta_ale==5) ); 
% DBX_aero.C_l_delta_ale = C_l_raw(idx)./deg2rad(delta_ale(idx)); 

% Hacer la media  
DBX_aero.C_l_delta_ale = mean( C_l_delta_ale(delta_ale_unique~=0)./deg2rad( delta_ale_unique(delta_ale_unique~=0) ) );

%% Generar C_m(alpha,Beta)
% close all
DBX_aero.C_m = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
        end
        try
            DBX_aero.C_m(i,j) = C_m_raw(idx);      
        end
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_m(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_m')
title('C_m vs beta vs alfa')

% return
% pause
%% Generar C_m_delta_elev(alpha,delta_elev)
DBX_aero.C_m_delta_elev = NaN*ones(size(Alpha_unique,1),size(delta_elev_unique,1) );
figure
hold on
grid
xlabel('Alpha')
ylabel('C_m_{\delta}_e')
title('C_m_{\delta}_{ele} vs, alfa vs. \delta_{elev}')

for j=1:size(delta_elev_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(j)).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        idx_zero = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==0) );
        try
            DBX_aero.C_m_delta_elev(i,j) = C_m_raw(idx) - C_m_raw(idx_zero);  % Este coeficiente es un Delta_coef
        catch
            DBX_aero.C_m_delta_elev(i,j) = 0;
        end
    end
    legend_str{j} = ['\delta_e ', num2str(delta_elev_unique(j))];
    plot(Alpha_unique,DBX_aero.C_m_delta_elev(:,j))
end
legend(legend_str)
% return
% pause
%% C_m_delta_ele efectivo
clear C_m_delta_ele_MAT
figure
surf(repmat(Alpha_unique,1,size(delta_elev_unique,1)),repmat(delta_elev_unique',size(Alpha_unique,1),1),DBX_aero.C_m_delta_elev(:,:))
xlabel('Alpha')
ylabel('\delta_{ele}')
zlabel('C_m_{\delta}_{elev}')
title('C_m_{\delta}_{elev} vs \delta_{ele} vs alfa')

for j=2:size(delta_elev_unique,1)-1
    for i=1:size(Alpha_unique,1)
%         if ~isnan(DBX_aero.C_m_delta_elev(i,j))
            C_m_delta_ele_MAT(i,j-1) = DBX_aero.C_m_delta_elev(i,j)./deg2rad( delta_elev_unique(j) );
%         end
    end
end
% surf(repmat(Alpha_unique,1,size(delta_elev_unique,1)),repmat(delta_elev_unique',size(Alpha_unique,1),1),C_m_delta_ele_MAT(:,:))

C_m_delta_ele_MAT_clean = C_m_delta_ele_MAT( ~isnan(C_m_delta_ele_MAT) );
DBX_aero.C_m_delta_elev_avrg =  mean(C_m_delta_ele_MAT_clean);
% pause

%% Generar C_n(alpha,beta)
% close all
DBX_aero.C_n = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
for j=1:size(Beta_unique,1)
    for i=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(i)).*(Beta==Beta_unique(j)) );
        % Filtrar el caso de Beta=90deg
        if (90==Beta_unique(j))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==90) );
        end
        % Filtrar el caso de alpha=90deg
        if (90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==90).*(Beta==0) );
        end
        % Filtrar el caso de alpha=-90deg
        if (-90==Alpha_unique(i))
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==-90).*(Beta==0) );
        end
        try
            DBX_aero.C_n(i,j) = C_n_raw(idx);      
        end
    end
end
figure
surf(repmat(Alpha_unique,1,size(Beta_unique,1)),repmat(Beta_unique',size(Alpha_unique,1),1),DBX_aero.C_n(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_n')
title('C_n vs beta vs alfa')

%% Generar C_n_delta_rud
C_n_delta_rud = NaN*ones(size(delta_rud_unique,1),1 );
figure
hold on
xlabel('delta_{rud}')
ylabel('C_n_{\delta}_{rud}')
title('C_n_{\delta}_{rud} vs \delta_{rud}')

for j=1:size(delta_rud_unique,1)
    idx = logical(  (delta_ale==0).*(delta_rud==delta_rud_unique(j)).*(delta_elev==0).*(Alfa==0).*(Beta==0) );
    try
        C_n_delta_rud(j) = C_n_raw(idx);  
    end
    
end
plot(delta_rud_unique,C_n_delta_rud)

% Escojer un caso
% idx = logical(  (delta_rud==-5) );
% DBX_aero.C_n_delta_rud = C_n_raw(idx)/deg2rad(delta_rud(idx)); 

% Hacer la media  
DBX_aero.C_n_delta_rud = mean( C_n_delta_rud(delta_rud_unique~=0)./deg2rad( delta_rud_unique(delta_rud_unique~=0) ) );


%% Generar C_n_delta_ale
C_n_delta_ale = NaN*ones(size(delta_ale_unique,1),1 );
figure
hold on
xlabel('\delta_{ale}')
ylabel('C_n_{\delta}_{ale}')
title('C_n_{\delta}_{ale} vs \delta_{ale}')

for j=1:size(delta_ale_unique,1)
    idx = logical(  (delta_ale==delta_ale_unique(j)).*(delta_rud==0).*(delta_elev==0).*(Alfa==0).*(Beta==0) );
    try
        C_n_delta_ale(j) = C_n_raw(idx);  
    end
end
plot(delta_ale_unique,C_n_delta_ale)

 % Escoger un caso
idx = logical(  (delta_ale==10)+(delta_ale==20) );
DBX_aero.C_n_delta_ale = mean( C_n_raw(idx)./deg2rad(delta_ale(idx)) ); 

% Hacer la media  
% DBX_aero.C_n_delta_ale = mean( C_n_delta_ale(delta_ale_unique~=0)./deg2rad( delta_ale_unique(delta_ale_unique~=0) ) );

%% Pasar las deflexones a rads!
DBX_aero.delta_elev_rad   = deg2rad(delta_elev_unique);
DBX_aero.alpha_rad        = deg2rad(Alpha_unique);
DBX_aero.beta_rad         = deg2rad(Beta_unique);
DBX_aero.delta_rud_rad    = deg2rad(delta_rud_unique);
DBX_aero.delta_ale_rad    = deg2rad(delta_ale_unique);

%% Definir los coeficientes de amortiguamiento

Importar_coef_amortiguacion

for i=1:size(DatosAeroDBXv2S2.Coefficients_damping ,1)
    if strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_Lift_q')
        % C_Lift_q
        DBX_aero.C_Lift_q = DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_D_q')
        % C_D_q
        DBX_aero.C_D_q = DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_Y_r')
        % C_Y_r
        DBX_aero.C_Y_r = DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_Y_p')
        % C_Y_p
        DBX_aero.C_Y_p = DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_l_p')
        % C_l_p
        DBX_aero.C_l_p = DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_l_r')
        % C_l_r
        DBX_aero.C_l_r = DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_m_q')
        % C_m_q
        DBX_aero.C_m_q =  DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_n_p')
        % C_n_p
        DBX_aero.C_n_p = DatosAeroDBXv2S2.value(i);
    elseif strcmp(DatosAeroDBXv2S2.Coefficients_damping(i),'C_n_r')
        % C_n_r
        DBX_aero.C_n_r = -0.1827;
    else
        errordlg(' Hay un error de nombres en los coeficientes de amortiguacion')
    end
    
    
end

%% Extra: Calculo de Centros Aerodinamicos
clear  legend_str
DBX_aero.x_CA = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );
figure
hold on
for j=1:3
    for i = 4:size(DBX_aero.C_L(:,j),1)-4
        C_m_alpha = (DBX_aero.C_m(i,j)-DBX_aero.C_m(i-1,j))/(DBX_aero.alpha_rad(i)-DBX_aero.alpha_rad(i-1));
        C_L_alpha = (DBX_aero.C_L(i,j)-DBX_aero.C_L(i-1,j))/(DBX_aero.alpha_rad(i)-DBX_aero.alpha_rad(i-1));
        DBX_aero.x_CA(i,j) = CMA*C_m_alpha/C_L_alpha;
    end
    plot(Alpha_unique,DBX_aero.x_CA(:,j))
    legend_str{j} = ['\beta ', num2str(Beta_unique(j))];
end
   
xlabel('Alpha(deg)')
ylabel('Beta(deg)')
zlabel('x_{CA}')
title('x_{CA} vs beta vs alfa')
legend(legend_str)
