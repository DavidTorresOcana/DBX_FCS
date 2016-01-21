% Extracción de datos de script de Xflow 2014 b94
% 
% Programa para usar con DBX v1
% 
% Genera una variable tipo struct con datos extraidos de simulaciones con
% los siguientes campos:
%
% xflow_data.filename   = string de nombre de archivo
% xflow_data.date       = string de fecha de creación
% xflow_data.speed      = Velocidad de ensayo (m/s)
% xflow_data.resolution = Resolución máxima en mm
% xflow_data.alfa       = Ángulo de ataque en deg
% xflow_data.beta       = Ángulo de resbalamiento en deg
% xflow_data.delta_a    = Mando alerones en deg
% xflow_data.delta_e    = Mando timón  en deg
% xflow_data.delta_r    = Mando dirección en deg
% xflow_data.Fx         = Valor promedio de Fx en ejes cuerpo (N)
% xflow_data.Fy         = Valor promedio de Fy en ejes cuerpo (N)
% xflow_data.Fz         = Valor promedio de Fz en ejes cuerpo (N)
% xflow_data.Mx         = Valor promedio de Mx en ejes cuerpo (N.m)
% xflow_data.My         = Valor promedio de My en ejes cuerpo (N.m)
% xflow_data.Mz         = Valor promedio de Mz en ejes cuerpo (N.m)
%
function xflow_data = get_xflow_data(filename,axis_matrix,sim_flag,time_proc)

%% Ejemplos

% % filename    = 'dbx_v1_s50_r16_am3_b0_da0_dem5_dr0.txt'; % Archivo ejemplo de datos
% % axis_matrix = [[-1 0 0];[0 1 0];[0 0 -1]]; % Matriz cambio de base
% % sim_flag = 1; %  Caso completo [0] Simetría habilitada [1]
% % time_proc = 0.4; % Tiempo ejemplo para filtrado


%% 1. Información general del archivo
xflow_data          = get_xflowfile_fields(filename);

%% 2. Extracción de datos

raw_data    = dlmread(filename,'\t',2,0);

% Memory allocate
vector_F_xflow = zeros(3,1);
vector_M_xflow = zeros(3,1);
vector_F_FA = zeros(size(raw_data,1),3);
vector_M_FA = zeros(size(raw_data,1),3);

%% 3. Acondicionamiento de datos

vector_time = raw_data(:,1);

for i = 10:size(raw_data,1)
    
    for j = 1:3
        
        vector_F_xflow(j,1) = raw_data(i,4+j);
        vector_M_xflow(j,1) = raw_data(i,7+j);
        
    end
    % Paso a ejes cuerpo habituales con axis_matrix
    kk_fuerzas = (axis_matrix * vector_F_xflow);
    kk_momentos = (axis_matrix * vector_M_xflow);
    
    if sim_flag == 1;
        
        vector_F_FA(i,1) = 2*kk_fuerzas(1,1);  % X = 2 * X_sim
        vector_F_FA(i,2) = 0;                  % Y = 0
        vector_F_FA(i,3) = 2*kk_fuerzas(3,1);  % Z = 2 * Z_sim
        vector_M_FA(i,1) = 0;                  % Mx = 0
        vector_M_FA(i,2) = 2*kk_momentos(2,1); % My = 2 * My
        vector_M_FA(i,3) = 0;                  % Mz = 0
        
    else
        
        for j = 1:3
            vector_F_FA(i,j) = kk_fuerzas(j,1);
            vector_M_FA(i,j) = kk_momentos(j,1);
        end
    
    end

    
end

%% 4. Procesado y salida de datos

for i = 1:size(vector_time)
    if vector_time(i) > time_proc
        counter_time = i;
        break
    end
end

xflow_data.time_start_s    = vector_time(counter_time);
xflow_data.time_end_s      = vector_time(end);

xflow_data.Fx_N            = mean (vector_F_FA(counter_time:end,1));
xflow_data.Fy_N            = mean (vector_F_FA(counter_time:end,2));
xflow_data.Fz_N            = mean (vector_F_FA(counter_time:end,3));
xflow_data.Mx_Nm            = mean (vector_M_FA(counter_time:end,1));
xflow_data.My_Nm            = mean (vector_M_FA(counter_time:end,2));
xflow_data.Mz_Nm            = mean (vector_M_FA(counter_time:end,3));

xflow_data.std.Fx_N        = std (vector_F_FA(counter_time:end,1))/abs(xflow_data.Fx_N);
xflow_data.std.Fy_N        = std (vector_F_FA(counter_time:end,2))/abs(xflow_data.Fy_N);
xflow_data.std.Fz_N        = std (vector_F_FA(counter_time:end,3))/abs(xflow_data.Fz_N);
xflow_data.std.Mx_Nm        = std (vector_M_FA(counter_time:end,1))/abs(xflow_data.Mx_Nm);
xflow_data.std.My_Nm        = std (vector_M_FA(counter_time:end,2))/abs(xflow_data.My_Nm);
xflow_data.std.Mz_Nm        = std (vector_M_FA(counter_time:end,3))/abs(xflow_data.Mz_Nm);

%% 5. Extracción de datos de archivo


end

