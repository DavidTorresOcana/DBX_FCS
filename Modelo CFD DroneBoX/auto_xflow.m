% Script de automatización de proceso de extracción
clear all
close all
clc

%% 1. Obtención de lista de ficheros en carpeta /data

addpath(pwd);
dir_list = get_xflow_dirs;
size_dir_list = size(dir_list,2);
counter_data = 1;

curr_path = pwd;
cd data
%% 2. Extracción de datos
% Extraer tabla CFD
Tabla_CFD = Import_CFD_table('Hoja de casos CFD.xlsx');

for i = 1:size_dir_list
    cd (dir_list{i})
    file_list_struct = get_xflow_files;
    
    % Bruteforce para casos con simetría
    axis_matrix = [[-1 0 0];[0 1 0];[0 0 -1]]; % Matriz cambio de base
        % Detectar la simetria del paqute
        idx = strcmp( dir_list{i},{Tabla_CFD{:,1}});
        if strcmp( 'SI',Tabla_CFD{idx,2})
            sim_flag = 1;
        else
            sim_flag = 0;
        end
    time_proc = 0.4;
    for j = 1:size(file_list_struct,1)
        xflow_data(counter_data) = get_xflow_data(file_list_struct(j).name,axis_matrix,sim_flag,time_proc);
        counter_data = counter_data+1;
    end
    
    cd ..
    
end

cd(curr_path)
%% Congruencia de signos
% De acuerdo con el documento Dropbox\DroneBoX\Ingeniería\03. Software y sistemas\SW\Modelado y FCS\Modelado\Guia xflow.docx 
for i = 1:size(xflow_data,2)
    xflow_data(i).delta_r_deg = - xflow_data(i).delta_r_deg;
end
%% 3. Comprobacion de convergencia de simulacion
for i = 1:size(xflow_data,2)
    % Creacion de metrica
    Cost(i) =  abs(xflow_data(i).std.Fx_N/xflow_data(i).Fx_N) ...
        + abs(xflow_data(i).std.Fy_N/xflow_data(i).Fy_N) ...
        + abs(xflow_data(i).std.Fz_N/xflow_data(i).Fz_N )...
        + abs(xflow_data(i).std.Mx_Nm/xflow_data(i).Mx_Nm) ...
        + abs(xflow_data(i).std.My_Nm/xflow_data(i).My_Nm )...
        + abs(xflow_data(i).std.Mz_Nm/xflow_data(i).Mz_Nm) ;
    
    if Cost(i) >0.1  % Esto es un criterio como cualqueir otro
        fprintf(' \n El caso %i no ha convergido',i)
        xflow_data(i);
    end
end

%% 4. Cambio de referencia: Body Axes Center (BAC) en la interseccion del plano de simetria X0Z con Borde de Salida
r_morro = [0.650163,0,0.179757 ] ; %Posicion del Morro desde BAC en ejes cuerpo (m)

for i = 1:size(xflow_data,2)
    % Angulos y demas
    Aero_Forc_Mom_data(i).speed_mps     = xflow_data(i).speed_mps;
    Aero_Forc_Mom_data(i).alfa_deg      = xflow_data(i).alfa_deg;
    Aero_Forc_Mom_data(i).beta_deg      = xflow_data(i).beta_deg;
    Aero_Forc_Mom_data(i).delta_a_deg   = xflow_data(i).delta_a_deg;
    Aero_Forc_Mom_data(i).delta_e_deg   = xflow_data(i).delta_e_deg;
    Aero_Forc_Mom_data(i).delta_r_deg   = xflow_data(i).delta_r_deg;
    % Fuerzas
    Aero_Forc_Mom_data(i).Fx_N          = xflow_data(i).Fx_N;
    Aero_Forc_Mom_data(i).Fy_N          = xflow_data(i).Fy_N;    
    Aero_Forc_Mom_data(i).Fz_N          = xflow_data(i).Fz_N;
    
    % Momentos y traslacion de fuerzas
    Moments = [xflow_data(i).Mx_Nm;xflow_data(i).My_Nm;xflow_data(i).Mz_Nm] + ...
        cross(r_morro, [xflow_data(i).Fx_N;xflow_data(i).Fy_N;xflow_data(i).Fz_N])';
    Aero_Forc_Mom_data(i).Mx_Nm         = Moments(1);
    Aero_Forc_Mom_data(i).My_Nm         = Moments(2);
    Aero_Forc_Mom_data(i).Mz_Nm         = Moments(3);
    
    %Fuerzas en Wind axes: FIXME: no se si esto esta bien
    Forces_F_w = BodyAxes2WindAxes_AoA( [xflow_data(i).Fx_N;xflow_data(i).Fy_N;xflow_data(i).Fz_N] ...
        ,deg2rad( xflow_data(i).alfa_deg )  );
    Aero_Forc_Mom_data(i).L_N           = - Forces_F_w(3);
    Aero_Forc_Mom_data(i).D_N           = - Forces_F_w(1);
    
end

%% 5. Adimesionalizacion
rho_ref     = 1.225; % Asegurarse que este es la densidad usada en XFlow!!
S_w         = 0.75; % m^2
b_span      = 3; % m wing span
CMA         = 0.25; % m cuerda media aerodinamica

for i = 1:size(xflow_data,2)
    TAS = Aero_Forc_Mom_data(i).speed_mps;
    q = 1/2*rho_ref*TAS^2;
    
    Aero_Coef_data(i).alfa_deg      = Aero_Forc_Mom_data(i).alfa_deg;
    Aero_Coef_data(i).beta_deg      = Aero_Forc_Mom_data(i).beta_deg;
    Aero_Coef_data(i).delta_a_deg   = Aero_Forc_Mom_data(i).delta_a_deg;
    Aero_Coef_data(i).delta_e_deg   = Aero_Forc_Mom_data(i).delta_e_deg;
    Aero_Coef_data(i).delta_r_deg   = Aero_Forc_Mom_data(i).delta_r_deg;
    
    Aero_Coef_data(i).C_x           = Aero_Forc_Mom_data(i).Fx_N/(q*S_w);
    Aero_Coef_data(i).C_y           = Aero_Forc_Mom_data(i).Fy_N/(q*S_w);    
    Aero_Coef_data(i).C_z           = Aero_Forc_Mom_data(i).Fz_N/(q*S_w);
    
    Aero_Coef_data(i).C_l           = Aero_Forc_Mom_data(i).Mx_Nm/(q*S_w*b_span);
    Aero_Coef_data(i).C_m           = Aero_Forc_Mom_data(i).My_Nm/(q*S_w*CMA);
    Aero_Coef_data(i).C_n           = Aero_Forc_Mom_data(i).Mz_Nm/(q*S_w*b_span);
    
    Aero_Coef_data(i).C_L           = Aero_Forc_Mom_data(i).L_N/(q*S_w);
    Aero_Coef_data(i).C_D           = Aero_Forc_Mom_data(i).D_N/(q*S_w);
    
end

%% 6. Guardar en un Excel para psost procesado
writetable( struct2table(Aero_Coef_data) ,'Datos Aero DBX v2.xlsx','Sheet','Raw Data')

if input(' \n Deseas post-procesar los datos?\n Si (1) \n No (2)\n ') ==1
    system('Datos Aero DBX v2.xlsx')
    return
end
    

%% 7. Crear lookup tables y aerocoef
DBX_aero_V2

%% 8. Cambiar  criterio de signos
% Del criterio tradicional (de La ETSIA) 
%  al definido en Dropbox\DroneBoX\Ingeniería\03. Software y sistemas\SW\Modelado y FCS\Modelado\Modelo aerodinamico V2.docx


% TODO