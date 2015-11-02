%% Scrip para calibrar los servos y la relacion entre su rotacion y la deflexion que crean
% El metodo se basa en obtener 3 puntos
% Punto A: Maxima deflexion de la superficie
% Punto B: Deflexion para el Servo en 1500us
% Punto C: Minima deflexion

% Nota (para servo de 180deg): Grados de servo = (us-1500)/400*90deg donde los us son los microsegundos  del PWM
% NOTA II: Si algun rango de PWM es diferente de 1100-1900usecs: Cambiarlo en todos lso modelos!
%% Introduccion datos de puntos
% Servo 1: motor delantero izquierdo
Servo_calib.Servo1.Punto_A.Servo_deg = -90; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo1.Punto_A.Deflexion_deg =90; % Maxima deflexion permitida

Servo_calib.Servo1.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo1.Punto_B.Deflexion_deg =0; % Deflexion de la superficie para 1500us

Servo_calib.Servo1.Punto_C.Servo_deg =5;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo1.Punto_C.Deflexion_deg = -5; % Minima deflexion permitida

% Servo 2: motor delantero derecho
Servo_calib.Servo2.Punto_A.Servo_deg = -90; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo2.Punto_A.Deflexion_deg =90; % Maxima deflexion permitida

Servo_calib.Servo2.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo2.Punto_B.Deflexion_deg =0; % Deflexion de la superficie para 1500us

Servo_calib.Servo2.Punto_C.Servo_deg =5;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo2.Punto_C.Deflexion_deg = -5; % Minima deflexion permitida
% Servo 3: motor trasero
Servo_calib.Servo3.Punto_A.Servo_deg = 25; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo3.Punto_A.Deflexion_deg =25; % Maxima deflexion permitida

Servo_calib.Servo3.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo3.Punto_B.Deflexion_deg =0; % Deflexion de la superficie para 1500us

Servo_calib.Servo3.Punto_C.Servo_deg =-25;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo3.Punto_C.Deflexion_deg = -25; % Minima deflexion permitida
% Servo 4:ruddervator izquierdo
Servo_calib.Servo4.Punto_A.Servo_deg = 25; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo4.Punto_A.Deflexion_deg =25; % Maxima deflexion permitida

Servo_calib.Servo4.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo4.Punto_B.Deflexion_deg =0; % Deflexion de la superficie para 1500us

Servo_calib.Servo4.Punto_C.Servo_deg =-25;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo4.Punto_C.Deflexion_deg = -25; % Minima deflexion permitida
% Servo 5:ruddervator derecho
Servo_calib.Servo5.Punto_A.Servo_deg = 25; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo5.Punto_A.Deflexion_deg =25; % Maxima deflexion permitida

Servo_calib.Servo5.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo5.Punto_B.Deflexion_deg =0; % Deflexion de la superficie para 1500us

Servo_calib.Servo5.Punto_C.Servo_deg =-25;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo5.Punto_C.Deflexion_deg = -25; % Minima deflexion permitida
% Servo 6: aleron izquierdo
Servo_calib.Servo6.Punto_A.Servo_deg = 25; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo6.Punto_A.Deflexion_deg =25; % Maxima deflexion permitida

Servo_calib.Servo6.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo6.Punto_B.Deflexion_deg =0; % Deflexion de la superficie para 1500us

Servo_calib.Servo6.Punto_C.Servo_deg =-25;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo6.Punto_C.Deflexion_deg = -25; % Minima deflexion permitida
% Servo 7: aleron derecho
Servo_calib.Servo7.Punto_A.Servo_deg = 25; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo7.Punto_A.Deflexion_deg =25; % Maxima deflexion permitida

Servo_calib.Servo7.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo7.Punto_B.Deflexion_deg =0; % Deflexion de la superficie para 1500us

Servo_calib.Servo7.Punto_C.Servo_deg =-25;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo7.Punto_C.Deflexion_deg = -25; % Minima deflexion permitida


%% Calculo de conversiones
% Servo 1
Servo_calib.Servo1.Pendiente_Sup_Servo = (Servo_calib.Servo1.Punto_A.Deflexion_deg -Servo_calib.Servo1.Punto_C.Deflexion_deg)/(Servo_calib.Servo1.Punto_A.Servo_deg-Servo_calib.Servo1.Punto_C.Servo_deg);
Servo_calib.Servo1.Sup_rad_0 = deg2rad(Servo_calib.Servo1.Punto_B.Deflexion_deg);
% Servo 2
Servo_calib.Servo2.Pendiente_Sup_Servo = (Servo_calib.Servo2.Punto_A.Deflexion_deg -Servo_calib.Servo2.Punto_C.Deflexion_deg)/(Servo_calib.Servo2.Punto_A.Servo_deg-Servo_calib.Servo2.Punto_C.Servo_deg);
Servo_calib.Servo2.Sup_rad_0 = deg2rad(Servo_calib.Servo2.Punto_B.Deflexion_deg);
% Servo 3
Servo_calib.Servo3.Pendiente_Sup_Servo = (Servo_calib.Servo3.Punto_A.Deflexion_deg -Servo_calib.Servo3.Punto_C.Deflexion_deg)/(Servo_calib.Servo3.Punto_A.Servo_deg-Servo_calib.Servo3.Punto_C.Servo_deg);
Servo_calib.Servo3.Sup_rad_0 = deg2rad(Servo_calib.Servo3.Punto_B.Deflexion_deg);
% Servo 4
Servo_calib.Servo4.Pendiente_Sup_Servo = (Servo_calib.Servo4.Punto_A.Deflexion_deg -Servo_calib.Servo4.Punto_C.Deflexion_deg)/(Servo_calib.Servo4.Punto_A.Servo_deg-Servo_calib.Servo4.Punto_C.Servo_deg);
Servo_calib.Servo4.Sup_rad_0 = deg2rad(Servo_calib.Servo4.Punto_B.Deflexion_deg);
% Servo 5
Servo_calib.Servo5.Pendiente_Sup_Servo = (Servo_calib.Servo5.Punto_A.Deflexion_deg -Servo_calib.Servo5.Punto_C.Deflexion_deg)/(Servo_calib.Servo5.Punto_A.Servo_deg-Servo_calib.Servo5.Punto_C.Servo_deg);
Servo_calib.Servo5.Sup_rad_0 = deg2rad(Servo_calib.Servo5.Punto_B.Deflexion_deg);
% Servo 6
Servo_calib.Servo6.Pendiente_Sup_Servo = (Servo_calib.Servo6.Punto_A.Deflexion_deg -Servo_calib.Servo6.Punto_C.Deflexion_deg)/(Servo_calib.Servo6.Punto_A.Servo_deg-Servo_calib.Servo6.Punto_C.Servo_deg);
Servo_calib.Servo6.Sup_rad_0 = deg2rad(Servo_calib.Servo6.Punto_B.Deflexion_deg);
% Servo 7
Servo_calib.Servo7.Pendiente_Sup_Servo = (Servo_calib.Servo7.Punto_A.Deflexion_deg -Servo_calib.Servo7.Punto_C.Deflexion_deg)/(Servo_calib.Servo7.Punto_A.Servo_deg-Servo_calib.Servo7.Punto_C.Servo_deg);
Servo_calib.Servo7.Sup_rad_0 = deg2rad(Servo_calib.Servo7.Punto_B.Deflexion_deg);


