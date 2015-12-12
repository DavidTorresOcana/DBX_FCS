%% Ajuste no-lienal parametrico del modelo aero:
% 
% C_X(alpha,beta) = 
% C_X_delta_elev(alpha,delta_elev) = 
% C_Y(alpha,beta) = 
% C_Y_delta_rud   =  
% C_Z(alpha,beta) = 
% C_Z_delta_elev(alpha,delta_elev) = 
% C_L(alpha,beta) = .
% C_L_delta_elev(alpha,delta_elev) = 
% C_D(alpha,beta) = 
% C_D_delta_elev(alpha,delta_elev) = 
% C_l(alpha,beta) = 
% C_l_delta_rud = 
% C_l_delta_ale = 
% C_m(alpha,Beta) = 
% C_m_delta_elev(alpha,delta_elev) = 
% C_n(alpha,beta)  =  
% C_n_delta_rud = 
% C_n_delta_ale = 

warning('off')
%% C_X(alpha,beta) = (a(1)+a(2)*alpha_rad+a(3)*alpha_rad^2+a(4)*alpha_rad^3+a(5)*alpha_rad^4)*(1-beta_rad^2)
% Definicion ajuste
DBX_aero_param.C_X.Expre    = '(a_1+a_2*alpha_rad+a_3*alpha_rad^2+a_4*alpha_rad^3+a_5*alpha_rad^4)*(1-beta_rad^2)';
DBX_aero_param.C_X.x_name   = 'alpha_rad';
DBX_aero_param.C_X.y_name   = 'beta_rad';
DBX_aero_param.C_X.z_name   = 'C_X';
DBX_aero_param.C_X.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_X.y        = DBX_aero.beta_rad(1:end-1);
DBX_aero_param.C_X.z        = DBX_aero.C_X(2:end-1,1:end-1);
DBX_aero_param.C_X.x_lim    = [max(DBX_aero_param.C_X.x),min(DBX_aero_param.C_X.x)];
DBX_aero_param.C_X.y_lim    = [max(DBX_aero_param.C_X.y),min(DBX_aero_param.C_X.y)];
DBX_aero_param.C_X.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_X);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_X.x ,DBX_aero_param.C_X.y ,...]
     DBX_aero_param.C_X.z,DBX_aero_param.C_X.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_X.z_name,'=vs. ',DBX_aero_param.C_X.x_name,' ',DBX_aero_param.C_X.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_X.x_name)
ylabel(DBX_aero_param.C_X.y_name)
zlabel(DBX_aero_param.C_X.z_name)
grid on

fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare); 
% Save params
DBX_aero_param.C_X  = Get_fitting_params(fitresult,DBX_aero_param.C_X);

%% C_X_delta_elev(alpha,delta_elev) = (a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3+a_4*alpha_rad^4) + a_5*delta_elev_rad + a_6*delta_elev_rad^2
clear DBX_aero_param.C_X_delta_elev
% Definicion ajuste
DBX_aero_param.C_X_delta_elev.Expre    = 'a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3 + a_4*delta_elev_rad + a_5*delta_elev_rad*alpha_rad + a_6*delta_elev_rad^2';
DBX_aero_param.C_X_delta_elev.x_name   = 'alpha_rad';
DBX_aero_param.C_X_delta_elev.y_name   = 'delta_elev_rad';
DBX_aero_param.C_X_delta_elev.z_name   = 'C_X_delta_elev';
DBX_aero_param.C_X_delta_elev.x        = DBX_aero.alpha_rad(2:end-3);
DBX_aero_param.C_X_delta_elev.y        = DBX_aero.delta_elev_rad;
DBX_aero_param.C_X_delta_elev.z        = DBX_aero.C_X_delta_elev(2:end-3,:);
DBX_aero_param.C_X_delta_elev.x_lim    = [max(DBX_aero_param.C_X_delta_elev.x),min(DBX_aero_param.C_X_delta_elev.x)];
DBX_aero_param.C_X_delta_elev.y_lim    = [max(DBX_aero_param.C_X_delta_elev.y),min(DBX_aero_param.C_X_delta_elev.y)];
DBX_aero_param.C_X_delta_elev.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_X_delta_elev);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_X_delta_elev.x ,DBX_aero_param.C_X_delta_elev.y ,...]
     DBX_aero_param.C_X_delta_elev.z,DBX_aero_param.C_X_delta_elev.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_X.z_name,'=vs. ',DBX_aero_param.C_X.x_name,' ',DBX_aero_param.C_X.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_X_delta_elev.x_name)
ylabel(DBX_aero_param.C_X_delta_elev.y_name)
zlabel(DBX_aero_param.C_X_delta_elev.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_X_delta_elev = Get_fitting_params(fitresult,DBX_aero_param.C_X_delta_elev);

%% C_Y(alpha,beta) = a_1*beta_rad + a_2*alpha_rad + a_3*beta_rad^2 + a_4*alpha_rad^2 + a_5*alpha_rad*beta_rad
% Definicion ajuste
DBX_aero_param.C_Y.Expre    = 'a_1*beta_rad + a_2*alpha_rad + a_3*beta_rad^2 + a_4*alpha_rad^2 + a_5*alpha_rad*beta_rad';
DBX_aero_param.C_Y.x_name   = 'alpha_rad';
DBX_aero_param.C_Y.y_name   = 'beta_rad';
DBX_aero_param.C_Y.z_name   = 'C_Y';
DBX_aero_param.C_Y.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_Y.y        = DBX_aero.beta_rad(1:end-1);
DBX_aero_param.C_Y.z        = DBX_aero.C_Y(2:end-1,1:end-1);
DBX_aero_param.C_Y.x_lim    = [max(DBX_aero_param.C_Y.x),min(DBX_aero_param.C_Y.x)];
DBX_aero_param.C_Y.y_lim    = [max(DBX_aero_param.C_Y.y),min(DBX_aero_param.C_Y.y)];
DBX_aero_param.C_Y.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_Y);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_Y.x ,DBX_aero_param.C_Y.y ,...]
     DBX_aero_param.C_Y.z,DBX_aero_param.C_Y.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_Y.z_name,'= vs. ',DBX_aero_param.C_Y.x_name,' ',DBX_aero_param.C_Y.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_Y.x_name)
ylabel(DBX_aero_param.C_Y.y_name)
zlabel(DBX_aero_param.C_Y.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare); 

% Save params
DBX_aero_param.C_Y  = Get_fitting_params(fitresult,DBX_aero_param.C_Y);

%% C_Y_delta_rud = constante
% Definicion ajuste
DBX_aero_param.C_Y_delta_rud   = DBX_aero.C_Y_delta_rud;

%% C_Z(alpha,beta) = (a(1)+a(2)*alpha_rad+a(3)*alpha_rad^2+a(4)*alpha_rad^3+a(5)*alpha_rad^4)*(1-beta_rad^2)
% Definicion ajuste
DBX_aero_param.C_Z.Expre    = '(a_1+a_2*alpha_rad+a_3*alpha_rad^2+a_4*alpha_rad^3+a_5*alpha_rad^4)*(1-beta_rad^2)';
DBX_aero_param.C_Z.x_name   = 'alpha_rad';
DBX_aero_param.C_Z.y_name   = 'beta_rad';
DBX_aero_param.C_Z.z_name   = 'C_Z';
DBX_aero_param.C_Z.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_Z.y        = DBX_aero.beta_rad(1:end-1);
DBX_aero_param.C_Z.z        = DBX_aero.C_Z(2:end-1,1:end-1);
DBX_aero_param.C_Z.x_lim    = [max(DBX_aero_param.C_Z.x),min(DBX_aero_param.C_Z.x)];
DBX_aero_param.C_Z.y_lim    = [max(DBX_aero_param.C_Z.y),min(DBX_aero_param.C_Z.y)];
DBX_aero_param.C_Z.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_Z);


[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_Z.x ,DBX_aero_param.C_Z.y ,...]
     DBX_aero_param.C_Z.z,DBX_aero_param.C_Z.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_Z.z_name,'=vs. ',DBX_aero_param.C_Z.x_name,' ',DBX_aero_param.C_Z.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_Z.x_name)
ylabel(DBX_aero_param.C_Z.y_name)
zlabel(DBX_aero_param.C_Z.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_Z  = Get_fitting_params(fitresult,DBX_aero_param.C_Z);

%% C_Z_delta_elev(alpha,delta_elev) = (a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3+a_4*alpha_rad^4) + a_5*delta_elev_rad + a_6*delta_elev_rad^2
clear DBX_aero_param.C_Z_delta_elev
% Definicion ajuste
DBX_aero_param.C_Z_delta_elev.Expre    = 'a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3 + a_4*delta_elev_rad + a_5*delta_elev_rad*alpha_rad + a_6*delta_elev_rad^2';
DBX_aero_param.C_Z_delta_elev.x_name   = 'alpha_rad';
DBX_aero_param.C_Z_delta_elev.y_name   = 'delta_elev_rad';
DBX_aero_param.C_Z_delta_elev.z_name   = 'C_Z_delta_elev';
DBX_aero_param.C_Z_delta_elev.x        = DBX_aero.alpha_rad(2:end-3);
DBX_aero_param.C_Z_delta_elev.y        = DBX_aero.delta_elev_rad;
DBX_aero_param.C_Z_delta_elev.z        = DBX_aero.C_Z_delta_elev(2:end-3,:);
DBX_aero_param.C_Z_delta_elev.x_lim    = [max(DBX_aero_param.C_Z_delta_elev.x),min(DBX_aero_param.C_Z_delta_elev.x)];
DBX_aero_param.C_Z_delta_elev.y_lim    = [max(DBX_aero_param.C_Z_delta_elev.y),min(DBX_aero_param.C_Z_delta_elev.y)];
DBX_aero_param.C_Z_delta_elev.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_Z_delta_elev);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_Z_delta_elev.x ,DBX_aero_param.C_Z_delta_elev.y ,...]
     DBX_aero_param.C_Z_delta_elev.z,DBX_aero_param.C_Z_delta_elev.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_Z.z_name,'=vs. ',DBX_aero_param.C_Z.x_name,' ',DBX_aero_param.C_Z.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_Z_delta_elev.x_name)
ylabel(DBX_aero_param.C_Z_delta_elev.y_name)
zlabel(DBX_aero_param.C_Z_delta_elev.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_Z_delta_elev = Get_fitting_params(fitresult,DBX_aero_param.C_Z_delta_elev);

%% C_L(alpha,beta) = (a(1)+a(2)*alpha_rad+a(3)*alpha_rad^2+a(4)*alpha_rad^3+a(5)*alpha_rad^4)*(1-beta_rad^2)
% Definicion ajuste
DBX_aero_param.C_L.Expre    = '(a_1+a_2*alpha_rad+a_3*alpha_rad^2+a_4*alpha_rad^3+a_5*alpha_rad^4)*(1-beta_rad^2)';
DBX_aero_param.C_L.x_name   = 'alpha_rad';
DBX_aero_param.C_L.y_name   = 'beta_rad';
DBX_aero_param.C_L.z_name   = 'C_L';
DBX_aero_param.C_L.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_L.y        = DBX_aero.beta_rad(1:end-1);
DBX_aero_param.C_L.z        = DBX_aero.C_L(2:end-1,1:end-1);
DBX_aero_param.C_L.x_lim    = [max(DBX_aero_param.C_L.x),min(DBX_aero_param.C_L.x)];
DBX_aero_param.C_L.y_lim    = [max(DBX_aero_param.C_L.y),min(DBX_aero_param.C_L.y)];
DBX_aero_param.C_L.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_L);


[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_L.x ,DBX_aero_param.C_L.y ,...]
     DBX_aero_param.C_L.z,DBX_aero_param.C_L.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_L.z_name,'=vs. ',DBX_aero_param.C_L.x_name,' ',DBX_aero_param.C_L.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_L.x_name)
ylabel(DBX_aero_param.C_L.y_name)
zlabel(DBX_aero_param.C_L.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_L  = Get_fitting_params(fitresult,DBX_aero_param.C_L);

%% C_L_delta_elev(alpha,delta_elev) = (a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3+a_4*alpha_rad^4) + a_5*delta_elev_rad + a_6*delta_elev_rad^2
clear DBX_aero_param.C_L_delta_elev
% Definicion ajuste
DBX_aero_param.C_L_delta_elev.Expre    = 'a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3 + a_4*delta_elev_rad + a_5*delta_elev_rad*alpha_rad + a_6*delta_elev_rad^2';
DBX_aero_param.C_L_delta_elev.x_name   = 'alpha_rad';
DBX_aero_param.C_L_delta_elev.y_name   = 'delta_elev_rad';
DBX_aero_param.C_L_delta_elev.z_name   = 'C_L_delta_elev';
DBX_aero_param.C_L_delta_elev.x        = DBX_aero.alpha_rad(2:end-3);
DBX_aero_param.C_L_delta_elev.y        = DBX_aero.delta_elev_rad;
DBX_aero_param.C_L_delta_elev.z        = DBX_aero.C_L_delta_elev(2:end-3,:);
DBX_aero_param.C_L_delta_elev.x_lim    = [max(DBX_aero_param.C_L_delta_elev.x),min(DBX_aero_param.C_L_delta_elev.x)];
DBX_aero_param.C_L_delta_elev.y_lim    = [max(DBX_aero_param.C_L_delta_elev.y),min(DBX_aero_param.C_L_delta_elev.y)];
DBX_aero_param.C_L_delta_elev.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_L_delta_elev);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_L_delta_elev.x ,DBX_aero_param.C_L_delta_elev.y ,...]
     DBX_aero_param.C_L_delta_elev.z,DBX_aero_param.C_L_delta_elev.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_L.z_name,'=vs. ',DBX_aero_param.C_L.x_name,' ',DBX_aero_param.C_L.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_L_delta_elev.x_name)
ylabel(DBX_aero_param.C_L_delta_elev.y_name)
zlabel(DBX_aero_param.C_L_delta_elev.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_L_delta_elev = Get_fitting_params(fitresult,DBX_aero_param.C_L_delta_elev);


%% C_D(alpha,beta) = (a(1)+a(2)*alpha_rad+a(3)*alpha_rad^2+a(4)*alpha_rad^3+a(5)*alpha_rad^4)*(1-beta_rad^2)
% Definicion ajuste
DBX_aero_param.C_D.Expre    = '(a_1+a_2*alpha_rad+a_3*alpha_rad^2+a_4*alpha_rad^3+a_5*alpha_rad^4)*(1-beta_rad^2)';
DBX_aero_param.C_D.x_name   = 'alpha_rad';
DBX_aero_param.C_D.y_name   = 'beta_rad';
DBX_aero_param.C_D.z_name   = 'C_D';
DBX_aero_param.C_D.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_D.y        = DBX_aero.beta_rad(1:end-1);
DBX_aero_param.C_D.z        = DBX_aero.C_D(2:end-1,1:end-1);
DBX_aero_param.C_D.x_lim    = [max(DBX_aero_param.C_D.x),min(DBX_aero_param.C_D.x)];
DBX_aero_param.C_D.y_lim    = [max(DBX_aero_param.C_D.y),min(DBX_aero_param.C_D.y)];
DBX_aero_param.C_D.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_D);


[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_D.x ,DBX_aero_param.C_D.y ,...]
     DBX_aero_param.C_D.z,DBX_aero_param.C_D.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_D.z_name,'=vs. ',DBX_aero_param.C_D.x_name,' ',DBX_aero_param.C_D.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_D.x_name)
ylabel(DBX_aero_param.C_D.y_name)
zlabel(DBX_aero_param.C_D.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_D  = Get_fitting_params(fitresult,DBX_aero_param.C_D);

%% C_D_delta_elev(alpha,delta_elev) = (a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3+a_4*alpha_rad^4) + a_5*delta_elev_rad + a_6*delta_elev_rad^2
clear DBX_aero_param.C_D_delta_elev
% Definicion ajuste
DBX_aero_param.C_D_delta_elev.Expre    = 'a_0+a_1*alpha_rad+a_2*alpha_rad^2+a_3*alpha_rad^3 + a_4*delta_elev_rad + a_5*delta_elev_rad*alpha_rad + a_6*delta_elev_rad^2';
DBX_aero_param.C_D_delta_elev.x_name   = 'alpha_rad';
DBX_aero_param.C_D_delta_elev.y_name   = 'delta_elev_rad';
DBX_aero_param.C_D_delta_elev.z_name   = 'C_D_delta_elev';
DBX_aero_param.C_D_delta_elev.x        = DBX_aero.alpha_rad(2:end-2);
DBX_aero_param.C_D_delta_elev.y        = DBX_aero.delta_elev_rad;
DBX_aero_param.C_D_delta_elev.z        = DBX_aero.C_D_delta_elev(2:end-2,:);
DBX_aero_param.C_D_delta_elev.x_lim    = [max(DBX_aero_param.C_D_delta_elev.x),min(DBX_aero_param.C_D_delta_elev.x)];
DBX_aero_param.C_D_delta_elev.y_lim    = [max(DBX_aero_param.C_D_delta_elev.y),min(DBX_aero_param.C_D_delta_elev.y)];
DBX_aero_param.C_D_delta_elev.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_D_delta_elev);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_D_delta_elev.x ,DBX_aero_param.C_D_delta_elev.y ,...]
     DBX_aero_param.C_D_delta_elev.z,DBX_aero_param.C_D_delta_elev.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_D.z_name,'=vs. ',DBX_aero_param.C_D.x_name,' ',DBX_aero_param.C_D.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_D_delta_elev.x_name)
ylabel(DBX_aero_param.C_D_delta_elev.y_name)
zlabel(DBX_aero_param.C_D_delta_elev.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_D_delta_elev = Get_fitting_params(fitresult,DBX_aero_param.C_D_delta_elev);


%% C_l(alpha,beta) = a_1*beta_rad+a_2*beta_rad*alpha_rad+a_3*alpha_rad^2*beta_rad+a_4*beta_rad^2+a_5*alpha_rad*beta_rad^2+a_6*alpha_rad^3*beta_rad+a_7*alpha_rad^4*beta_rad+a_8*alpha_rad^2*beta_rad^2
% Definicion ajuste
DBX_aero_param.C_l.Expre    = 'a_1*beta_rad+a_2*beta_rad*alpha_rad+a_3*alpha_rad^2*beta_rad+a_4*beta_rad^2+a_5*alpha_rad*beta_rad^2+a_6*alpha_rad^3*beta_rad+a_7*alpha_rad^4*beta_rad+a_8*alpha_rad^2*beta_rad^2';
DBX_aero_param.C_l.x_name   = 'alpha_rad';
DBX_aero_param.C_l.y_name   = 'beta_rad';
DBX_aero_param.C_l.z_name   = 'C_l';
DBX_aero_param.C_l.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_l.y        = DBX_aero.beta_rad(1:end-2);
DBX_aero_param.C_l.z        = DBX_aero.C_l(2:end-1,1:end-2);
DBX_aero_param.C_l.x_lim    = [max(DBX_aero_param.C_l.x),min(DBX_aero_param.C_l.x)];
DBX_aero_param.C_l.y_lim    = [max(DBX_aero_param.C_l.y),min(DBX_aero_param.C_l.y)];
DBX_aero_param.C_l.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_l);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_l.x ,DBX_aero_param.C_l.y ,...]
     DBX_aero_param.C_l.z,DBX_aero_param.C_l.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_l.z_name,'=vs. ',DBX_aero_param.C_l.x_name,' ',DBX_aero_param.C_l.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_l.x_name)
ylabel(DBX_aero_param.C_l.y_name)
zlabel(DBX_aero_param.C_l.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare); 

% Save params
DBX_aero_param.C_l  = Get_fitting_params(fitresult,DBX_aero_param.C_l);

%% C_l_delta_rud = constante
% Definicion ajuste
DBX_aero_param.C_l_delta_rud   = DBX_aero.C_l_delta_rud;
%% C_l_delta_ale = constante
% Definicion ajuste
DBX_aero_param.C_l_delta_ale   = DBX_aero.C_l_delta_ale;

%% C_m(alpha,beta) = (a(1)+a(2)*alpha_rad+a(3)*alpha_rad^2+a(4)*alpha_rad^3+a(5)*alpha_rad^4)*(1-beta_rad^2)
% Definicion ajuste
DBX_aero_param.C_m.Expre    = '(a_1+a_2*alpha_rad+a_3*alpha_rad^2+a_4*alpha_rad^3+a_5*alpha_rad^4)*(1+a_6*beta_rad^2+a_7*beta_rad^4)';
DBX_aero_param.C_m.x_name   = 'alpha_rad';
DBX_aero_param.C_m.y_name   = 'beta_rad';
DBX_aero_param.C_m.z_name   = 'C_m';
DBX_aero_param.C_m.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_m.y        = DBX_aero.beta_rad(1:end-1);
DBX_aero_param.C_m.z        = DBX_aero.C_m(2:end-1,1:end-1);
DBX_aero_param.C_m.x_lim    = [max(DBX_aero_param.C_m.x),min(DBX_aero_param.C_m.x)];
DBX_aero_param.C_m.y_lim    = [max(DBX_aero_param.C_m.y),min(DBX_aero_param.C_m.y)];
DBX_aero_param.C_m.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_m);


[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_m.x ,DBX_aero_param.C_m.y ,...]
     DBX_aero_param.C_m.z,DBX_aero_param.C_m.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_m.z_name,'=vs. ',DBX_aero_param.C_m.x_name,' ',DBX_aero_param.C_m.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_m.x_name)
ylabel(DBX_aero_param.C_m.y_name)
zlabel(DBX_aero_param.C_m.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_m  = Get_fitting_params(fitresult,DBX_aero_param.C_m);

%% C_m_delta_elev(alpha,delta_elev) = a_1*alpha_rad+a_2*delta_elev_rad+a_3*alpha_rad*delta_elev_rad+a_4*delta_elev_rad^2+a_5*alpha_rad^2*delta_elev_rad+a_6*delta_elev_rad^3+a_7*alpha_rad*delta_elev_rad^2
clear DBX_aero_param.C_m_delta_elev
% Definicion ajuste
DBX_aero_param.C_m_delta_elev.Expre    = 'a_1*alpha_rad+a_2*delta_elev_rad+a_3*alpha_rad*delta_elev_rad+a_4*delta_elev_rad^2+a_5*alpha_rad^2*delta_elev_rad+a_6*delta_elev_rad^3+a_7*alpha_rad*delta_elev_rad^2';
DBX_aero_param.C_m_delta_elev.x_name   = 'alpha_rad';
DBX_aero_param.C_m_delta_elev.y_name   = 'delta_elev_rad';
DBX_aero_param.C_m_delta_elev.z_name   = 'C_m_delta_elev';
DBX_aero_param.C_m_delta_elev.x        = DBX_aero.alpha_rad(2:end-2);
DBX_aero_param.C_m_delta_elev.y        = DBX_aero.delta_elev_rad;
DBX_aero_param.C_m_delta_elev.z        = DBX_aero.C_m_delta_elev(2:end-2,:);
DBX_aero_param.C_m_delta_elev.x_lim    = [max(DBX_aero_param.C_m_delta_elev.x),min(DBX_aero_param.C_m_delta_elev.x)];
DBX_aero_param.C_m_delta_elev.y_lim    = [max(DBX_aero_param.C_m_delta_elev.y),min(DBX_aero_param.C_m_delta_elev.y)];
DBX_aero_param.C_m_delta_elev.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_m_delta_elev);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_m_delta_elev.x ,DBX_aero_param.C_m_delta_elev.y ,...]
     DBX_aero_param.C_m_delta_elev.z,DBX_aero_param.C_m_delta_elev.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_m_delta_elev.z_name,'=vs. ',DBX_aero_param.C_m_delta_elev.x_name,' ',DBX_aero_param.C_m_delta_elev.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_m_delta_elev.x_name)
ylabel(DBX_aero_param.C_m_delta_elev.y_name)
zlabel(DBX_aero_param.C_m_delta_elev.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare);

% Save params
DBX_aero_param.C_m_delta_elev = Get_fitting_params(fitresult,DBX_aero_param.C_m_delta_elev);

%% C_m_delta_elev_GRAD(alpha,delta_elev) = a_1*alpha_rad+a_2+a_3*alpha_rad+a_4*delta_elev_rad+a_5*alpha_rad^2*+a_6*delta_elev_rad^2+a_7*alpha_rad*delta_elev_rad
clear DBX_aero_param.C_m_delta_elev_GRAD
DBX_aero_param.C_m_delta_elev_GRAD = DBX_aero_param.C_m_delta_elev;
% Definicion ajuste
DBX_aero_param.C_m_delta_elev_GRAD.Expre    = 'a_1*alpha_rad+a_2+a_3*alpha_rad+a_4*delta_elev_rad+a_5*alpha_rad^2*+a_6*delta_elev_rad^2+a_7*alpha_rad*delta_elev_rad';
DBX_aero_param.C_m_delta_elev_GRAD.x_name   = 'alpha_rad';
DBX_aero_param.C_m_delta_elev_GRAD.y_name   = 'delta_elev_rad';
DBX_aero_param.C_m_delta_elev_GRAD.z_name   = 'C_m_delta_elev_GRAD';
DBX_aero_param.C_m_delta_elev_GRAD.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_m_delta_elev_GRAD);

%% C_n(alpha,beta) = a_1*beta_rad+a_2*beta_rad*alpha_rad+a_3*alpha_rad^2*beta_rad+a_4*beta_rad^2+a_5*alpha_rad*beta_rad^2+a_6*alpha_rad^3*beta_rad+a_7*alpha_rad^4*beta_rad+a_8*alpha_rad^2*beta_rad^2
% Definicion ajuste
DBX_aero_param.C_n.Expre    = 'a_1*beta_rad+a_2*beta_rad*alpha_rad+a_3*alpha_rad^2*beta_rad+a_4*beta_rad^2+a_5*alpha_rad*beta_rad^2+a_6*alpha_rad^3*beta_rad+a_7*alpha_rad^4*beta_rad+a_8*alpha_rad^2*beta_rad^2';
DBX_aero_param.C_n.x_name   = 'alpha_rad';
DBX_aero_param.C_n.y_name   = 'beta_rad';
DBX_aero_param.C_n.z_name   = 'C_n';
DBX_aero_param.C_n.x        = DBX_aero.alpha_rad(2:end-1);
DBX_aero_param.C_n.y        = DBX_aero.beta_rad(1:end-2);
DBX_aero_param.C_n.z        = DBX_aero.C_n(2:end-1,1:end-2);
DBX_aero_param.C_n.x_lim    = [max(DBX_aero_param.C_n.x),min(DBX_aero_param.C_n.x)];
DBX_aero_param.C_n.y_lim    = [max(DBX_aero_param.C_n.y),min(DBX_aero_param.C_n.y)];
DBX_aero_param.C_n.Expre_regu   = Get_regular_fitting_expre(DBX_aero_param.C_n);

[fitresult, gof,hand]  = Custom_Fit(DBX_aero_param.C_n.x ,DBX_aero_param.C_n.y ,...]
     DBX_aero_param.C_n.z,DBX_aero_param.C_n.Expre_regu);
legend( hand, 'untitled fit 1', [DBX_aero_param.C_n.z_name,'=vs. ',DBX_aero_param.C_n.x_name,' ',DBX_aero_param.C_n.y_name], 'Location', 'NorthEast' );
% Label axes
xlabel(DBX_aero_param.C_n.x_name)
ylabel(DBX_aero_param.C_n.y_name)
zlabel(DBX_aero_param.C_n.z_name)
grid on
fprintf('\n\n       Ajuste R^2 =  %0.2f', gof.rsquare); 

% Save params
DBX_aero_param.C_n  = Get_fitting_params(fitresult,DBX_aero_param.C_n);

%% C_n_delta_rud = constante
% Definicion ajuste
DBX_aero_param.C_n_delta_rud   = DBX_aero.C_n_delta_rud;
%% C_n_delta_ale = constante
% Definicion ajuste
DBX_aero_param.C_n_delta_ale   = DBX_aero.C_n_delta_ale;


%% Definir los coeficientes de amortiguamiento

DBX_aero_param.C_Lift_q   = DBX_aero.C_Lift_q;
DBX_aero_param.C_D_q  =DBX_aero.C_D_q;
DBX_aero_param.C_Y_r  =DBX_aero.C_Y_r;
DBX_aero_param.C_Y_p  =DBX_aero.C_Y_p;
DBX_aero_param.C_l_p  =DBX_aero.C_l_p;
DBX_aero_param.C_l_r  =DBX_aero.C_l_r;
DBX_aero_param.C_m_q  =DBX_aero.C_m_q;
DBX_aero_param.C_n_p  =DBX_aero.C_n_p;
DBX_aero_param.C_n_r  =DBX_aero.C_n_r;

%% Extra: Calculo de Centros Aerodinamicos
% x_CA = C_m_alpha/C_L_alpha*CMA
% C_m_alpha(alpha,beta) = (a(2)+a(3)*alpha_rad+a(4)*alpha_rad^2+a(5)*alpha_rad^3)*(1-beta_rad^2);
% C_L_alpha(alpha,beta) = (a(2)+a(3)*alpha_rad+a(4)*alpha_rad^2+a(5)*alpha_rad^3)*(1-beta_rad^2)

for i=2:size(DBX_aero_param.C_L.x,1)-1
    alpha_rad = DBX_aero_param.C_L.x(i);
    x_CA(i) = (DBX_aero_param.C_m.a(2)+DBX_aero_param.C_m.a(3)*alpha_rad+DBX_aero_param.C_m.a(4)*alpha_rad^2+DBX_aero_param.C_m.a(5)*alpha_rad^3)/...
        (DBX_aero_param.C_L.a(2)+DBX_aero_param.C_L.a(3)*alpha_rad+DBX_aero_param.C_L.a(4)*alpha_rad^2+DBX_aero_param.C_L.a(5)*alpha_rad^3)*CMA;
end

plot(DBX_aero_param.C_L.x(1:end-1),x_CA)
xlabel('Alpha(rad)')
ylabel('x_{CA} (m)')
title('x_{CA} vs alfa')


