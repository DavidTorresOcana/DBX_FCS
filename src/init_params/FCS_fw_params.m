
%% Define controller gains for closed loop case

% Autopilot
Kp_h = 0.1;
Ki_h = 0.05;
Kd_h = 0.05;

Kp_u = 0.1;
Ki_u = 0.03;

% Attitude Control
Kp_theta = 3;
Ki_theta = 0.1;

Kp_phi = 10;
Ki_phi = 0.5;

% Rates Control
Kp_q = 0.07;
Ki_q = 0.01;

Kp_p = 0.01;
Ki_p = 0;

%% Mixing de canales
% We have to be careful with the signs here:
% Acordign with Dropbox\DroneBoX\Ingeniería\03. Software y sistemas\SW\Modelado y FCS\Modelado\Modelo aerodinamico V2.docx
%        delta_rudd          delta_elev         delta_ail
% C_l   C_l_delta_rud             0           C_l_delta_ale
% C_m       0              C_m_delta_elev_avrg         0
% C_n  C_n_delta_rud          0         C_n_delta_ale   


B = [ DBX_aero.C_l_delta_rud          0         -DBX_aero.C_l_delta_ale;
       0              -DBX_aero.C_m_delta_elev_avrg         0;
      DBX_aero.C_n_delta_rud          0         -DBX_aero.C_n_delta_ale   ];
   
 B_adim = B;
 B_adim(1,:) =  B_adim(1,:)/norm( B_adim(1,:));
 B_adim(2,:) =  B_adim(2,:)/norm( B_adim(2,:));
 B_adim(3,:) =  B_adim(3,:)/norm( B_adim(3,:));

 FCS_control_mix = inv(B_adim);
 
 % Flaps
 Flaps_ang_deg=0;
 