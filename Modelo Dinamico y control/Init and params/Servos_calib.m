%% Scrip para calibrar los servos y la relacion entre su rotacion y la deflexion que crean
% El metodo se basa en obtener 3 puntos
% Punto A: Maxima deflexion de la superficie
% Punto B: Deflexion para el Servo en 1500us
% Punto C: Minima deflexion

% Nota (para servo de 180deg): Grados de servo = (us-1500)/600*90deg donde los us son los microsegundos  del PWM
% NOTA II: Si algun rango de PWM es diferente de 900-2100usecs: Cambiarlo en todos lso modelos!

%% Introduccion datos de puntos
% Servo 1: motor delantero izquierdo
Servo_calib.Servo1.Punto_A.Servo_deg = -8.1; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo1.Punto_A.Deflexion_deg =4.5; % Maxima deflexion permitida

Servo_calib.Servo1.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo1.Punto_B.Deflexion_deg =-2.5; % Deflexion de la superficie para 1500us

Servo_calib.Servo1.Punto_C.Servo_deg =63.6 ;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo1.Punto_C.Deflexion_deg = -90; % Minima deflexion permitida

% Servo 2: motor delantero derecho
Servo_calib.Servo2.Punto_A.Servo_deg = -1.2; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo2.Punto_A.Deflexion_deg =5.5; % Maxima deflexion permitida

Servo_calib.Servo2.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo2.Punto_B.Deflexion_deg =-4; % Deflexion de la superficie para 1500us

Servo_calib.Servo2.Punto_C.Servo_deg =57.15;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo2.Punto_C.Deflexion_deg = -90; % Minima deflexion permitida
% Servo 3: motor trasero
Servo_calib.Servo3.Punto_A.Servo_deg = 23.55; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo3.Punto_A.Deflexion_deg =25; % Maxima deflexion permitida

Servo_calib.Servo3.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo3.Punto_B.Deflexion_deg =-5; % Deflexion de la superficie para 1500us

Servo_calib.Servo3.Punto_C.Servo_deg =-13.2;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo3.Punto_C.Deflexion_deg = -20; % Minima deflexion permitida
% Servo 4:ruddervator izquierdo
Servo_calib.Servo4.Punto_A.Servo_deg = -66.3; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo4.Punto_A.Deflexion_deg =47; % Maxima deflexion permitida

Servo_calib.Servo4.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo4.Punto_B.Deflexion_deg =-4; % Deflexion de la superficie para 1500us

Servo_calib.Servo4.Punto_C.Servo_deg =16.8;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo4.Punto_C.Deflexion_deg = -20; % Minima deflexion permitida
% Servo 5:ruddervator derecho
Servo_calib.Servo5.Punto_A.Servo_deg = 36.45; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo5.Punto_A.Deflexion_deg =39; % Maxima deflexion permitida

Servo_calib.Servo5.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo5.Punto_B.Deflexion_deg =7; % Deflexion de la superficie para 1500us

Servo_calib.Servo5.Punto_C.Servo_deg =-27.9;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo5.Punto_C.Deflexion_deg = -24; % Minima deflexion permitida
% Servo 6: aleron izquierdo
Servo_calib.Servo6.Punto_A.Servo_deg = -55.2; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo6.Punto_A.Deflexion_deg =30; % Maxima deflexion permitida

Servo_calib.Servo6.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo6.Punto_B.Deflexion_deg =1; % Deflexion de la superficie para 1500us

Servo_calib.Servo6.Punto_C.Servo_deg =21.45;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo6.Punto_C.Deflexion_deg = -14; % Minima deflexion permitida
% Servo 7: aleron derecho
Servo_calib.Servo7.Punto_A.Servo_deg = 89.85; % Rotacion del servo para maxima deflexion permitida
Servo_calib.Servo7.Punto_A.Deflexion_deg =44; % Maxima deflexion permitida

Servo_calib.Servo7.Punto_B.Servo_deg = 0; % Por definicion esto es 0
Servo_calib.Servo7.Punto_B.Deflexion_deg =-1; % Deflexion de la superficie para 1500us

Servo_calib.Servo7.Punto_C.Servo_deg =-21.45;  % Rotacion del servo para Minima deflexion permitida
Servo_calib.Servo7.Punto_C.Deflexion_deg = -14; % Minima deflexion permitida


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


