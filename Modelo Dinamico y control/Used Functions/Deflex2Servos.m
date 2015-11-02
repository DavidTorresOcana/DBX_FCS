
eta_1_0_servo = (eta_1_0 - Servo_calib.Servo1.Sup_rad_0)/Servo_calib.Servo1.Pendiente_Sup_Servo;
eta_2_0_servo = (eta_2_0 - Servo_calib.Servo2.Sup_rad_0)/Servo_calib.Servo2.Pendiente_Sup_Servo;
eta_3_0_servo = (eta_3_0 - Servo_calib.Servo3.Sup_rad_0)/Servo_calib.Servo3.Pendiente_Sup_Servo;

% Demix
delta_rv_L_0_servo = (delta_rv_L_0 - Servo_calib.Servo4.Sup_rad_0)/Servo_calib.Servo4.Pendiente_Sup_Servo;
delta_rv_R_0_servo = (delta_rv_R_0 - Servo_calib.Servo5.Sup_rad_0)/Servo_calib.Servo5.Pendiente_Sup_Servo;
delta_a_L_0_servo  = (delta_a_L_0 - Servo_calib.Servo6.Sup_rad_0)/Servo_calib.Servo6.Pendiente_Sup_Servo;
delta_a_R_0_servo  = (delta_a_R_0 - Servo_calib.Servo7.Sup_rad_0)/Servo_calib.Servo7.Pendiente_Sup_Servo;

% [eta_1_0_servo,eta_3_0_servo,eta_3_0_servo,delta_rv_L_0_servo,delta_rv_R_0_servo,delta_a_L_0_servo,delta_a_R_0_servo]'