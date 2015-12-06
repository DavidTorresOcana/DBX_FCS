%% Import the data
[~, ~, raw0_0] = xlsread('.\Datos Aero DBX v1.xlsx','Datos RAW','A2:E52');
[~, ~, raw0_1] = xlsread('.\Datos Aero DBX v1.xlsx','Datos RAW','AA2:AF52');
raw = [raw0_0,raw0_1];
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

%% Replace non-numeric cells with NaN
RRR = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(RRR) = {NaN}; % Replace non-numeric cells

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
Alfa = data(2:end,1);
Beta = data(2:end,2);
delta_ale = data(2:end,3);
delta_elev = data(2:end,4);
delta_rud = data(2:end,5);
C_x = data(2:end,6);
C_y = data(2:end,7);
C_z = data(2:end,8);
C_l_raw = data(2:end,9);
C_m_raw = data(2:end,10);
C_n_raw = data(2:end,11);

%% Clear temporary variables
clearvars data raw raw0_0 raw0_1 RRR;

%% Generar C_X(alpha,beta,delta_e,deltas=0)
delta_elev_unique = unique(delta_elev);
Alpha_unique = unique(Alfa);
Beta_unique = unique(Beta);
C_X = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1),size(delta_elev_unique,1) );

for i=1:size(delta_elev_unique,1)
    idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)) );
    for j=1:size(Beta_unique,1)
        for k=1:size(Alpha_unique,1)
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k)).*(Beta==Beta_unique(j)) );
            try 
                C_X(k,j,i) = C_x(idx);
            catch
                idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-2)).*(Beta==Beta_unique(j)) );
                PrevPrev = C_x(idx);
                idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-1)).*(Beta==Beta_unique(j)) );
                Prev = C_x(idx);
                slope=(Prev-PrevPrev)/(Alpha_unique(k-1)-Alpha_unique(k-2));
                C_X(k,j,i) = C_x(idx)+slope*(Alpha_unique(k)-Alpha_unique(k-1));
            end
        end
    end
    figure
    surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_X(:,:,i))
    grid
    xlabel('Alpha')
    ylabel('Beta')
    zlabel('C_X')
    title(['\delta_{elev} = ',num2str(delta_elev_unique(i)),'deg'])
end


% C_Lift_q
C_Lift_q = 10.9; 
% C_D_q
C_D_q = 0.0336; 
% return
pause
%% Generar C_Y(alpha,beta,deltas=0)
close all
delta_elev_unique = unique(delta_elev);
Alpha_unique = unique(Alfa);
Beta_unique = unique(Beta);
C_Y = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1) );

for j=1:size(Beta_unique,1)
    for k=1:size(Alpha_unique,1)
        idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==0).*(Alfa==Alpha_unique(k)).*(Beta==Beta_unique(j)) );
%         if sum(C_x(idx))
            C_Y(k,j) = C_y(idx);
%         end
    end
    
end
figure
surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_Y(:,:))
xlabel('Alpha')
ylabel('Beta')
zlabel('C_Y')

% C_Y_delta_rv_Asim
delta_rud_unique = unique(delta_rud);
idx = logical(  (delta_rud==delta_rud_unique(2)) );
C_Y_delta_rv_Asim = C_y(idx)/deg2rad(delta_rud(idx));
% C_Y_r
C_Y_r = 0.5219;
% C_Y_p
C_Y_p = -0.0991;
% return
pause
%% Generar C_Z(alpha,beta,delta_e,deltas=0)
close all
delta_elev_unique = unique(delta_elev);
Alpha_unique = unique(Alfa);
Beta_unique = unique(Beta);
C_Z = NaN*ones(size(Alpha_unique,1),size(Beta_unique,1),size(delta_elev_unique,1) );


for i=1:size(delta_elev_unique,1)
    idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)) );
    for j=1:size(Beta_unique,1)
        for k=1:size(Alpha_unique,1)
            idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k)).*(Beta==Beta_unique(j)) );
            try 
                C_Z(k,j,i) = C_z(idx);
            catch
                idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-2)).*(Beta==Beta_unique(j)) );
                PrevPrev = C_z(idx);
                idx = logical(  (delta_ale==0).*(delta_rud==0).*(delta_elev==delta_elev_unique(i)).*(Alfa==Alpha_unique(k-1)).*(Beta==Beta_unique(j)) );
                Prev = C_z(idx);
                slope=(Prev-PrevPrev)/(Alpha_unique(k-1)-Alpha_unique(k-2));
                C_Z(k,j,i) = C_z(idx)+slope*(Alpha_unique(k)-Alpha_unique(k-1));
            end
        end
    end
    figure
    
    surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_Z(:,:,i))
    
    xlabel('Alpha')
    ylabel('Beta')
    zlabel('C_Z')
    title(['\delta_{elev} = ',num2str(delta_elev_unique(i)),'deg'])
    
end

% return
pause
%% Generar C_l(alpha,beta,deltas=0)
close all
delta_elev_unique = unique(delta_elev);
Alpha_unique = unique(Alfa);
Beta_unique = unique(Beta);
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
delta_ale_unique = unique(delta_ale);
idx = logical(  (delta_ale==delta_ale_unique(2)) );

C_l_delta_a_Asim = C_l_raw(idx)/deg2rad(delta_ale(idx));
% C_l_p
C_l_p = -0.8333;
% C_l_r
C_l_r = 0.0347;

pause

%% Generar C_m(alpha,delta_elev=delta_rv_sim,deltas=0)
close all
delta_elev_unique = unique(delta_elev);
Alpha_unique = unique(Alfa);
Beta_unique = unique(Beta);
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

% C_m_q
C_m_q = -45.7828;

% C_m_delta_ele efectivo
C_m_delta_ele_MAT = (C_m(:,:,3)-C_m(:,:,1))./deg2rad(delta_elev_unique(3)-delta_elev_unique(1)),
surf(repmat(Alpha_unique,1,3),repmat(Beta_unique',6,1),C_m_delta_ele_MAT)

C_m_delta_rv_sim = mean(C_m_delta_ele_MAT(1:end-1,2));

pause

%% Generar C_n(alpha,beta,deltas=0)
close all
delta_elev_unique = unique(delta_elev);
Alpha_unique = unique(Alfa);
Beta_unique = unique(Beta);
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
delta_rud_unique = unique(delta_rud);
idx = logical(  (delta_rud==delta_rud_unique(2)) );
C_n_delta_rv_Asim = C_n_raw(idx)/deg2rad(delta_rud(idx));

% C_l_delta_a_Asim
delta_ale_unique = unique(delta_ale);
idx = logical(  (delta_ale==delta_ale_unique(2)) );

C_n_delta_a_Asim = C_n_raw(idx)/deg2rad(delta_ale(idx));

% C_n_p
C_n_p = -0.0066;
% C_n_r
C_n_r = -0.1827;

pause

% A rads!
delta_elev_unique_rad = deg2rad(delta_elev_unique);
Alpha_unique_rad = deg2rad(Alpha_unique);
Beta_unique_rad = deg2rad(Beta_unique);


