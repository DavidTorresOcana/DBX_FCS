
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
%        delta_RV_A          delta_RV_S         delta_a_A
% C_l  C_l_delta_rv_Asim          0         C_l_delta_a_Asim
% C_m       0              C_m_delta_rv_sim         0
% C_n  C_n_delta_rv_Asim          0         C_n_delta_a_Asim   


B = [ C_l_delta_rv_Asim          0         C_l_delta_a_Asim;
       0              C_m_delta_rv_sim         0;
      C_n_delta_rv_Asim          0         C_n_delta_a_Asim   ];
   
 B_adim = B;
 B_adim(1,:) =  B_adim(1,:)/norm( B_adim(1,:));
 B_adim(2,:) =  B_adim(2,:)/norm( B_adim(2,:));
 B_adim(3,:) =  B_adim(3,:)/norm( B_adim(3,:));

 B_adim

 FCS_control_mix = inv(B_adim);
 
 % Flaps
 Flaps_ang_deg=0;
 