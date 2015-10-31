%aerosonde_data.m
%   Aerosonde UAV Initialization Routine
%   
%  To run the aerosonde model, the aircraft data is required. 
%  Obtain by typing
%       aerosonde=aerosonde_data
%  into the command interface

%   Copyright 2002 Unmanned Dynamics, LLC 
%   Modified JFW using Mathworks Aerospace Blockset 25 May 2010
%   For internal use only

function aerosonde=aerosonde_data

%%% AERODYNAMICS %%%
% Aerodynamic force application point (usually the aerodynamic center)[x y z]
aerosonde.rAC = [0.1425 0 0]; % m

%%% Aerodynamic parameter bounds %%%
% Airspeed bounds
aerosonde.VaBnd = [15 50]; % m/s
% Sideslip angle bounds
aerosonde.BetaBnd = [-0.5 0.5]; % rad
% Angle of attack bounds
aerosonde.AlphaBnd = [-0.1 0.3]; % rad

%%% Aerodynamic reference parameters %%%
% Mean aerodynamic chord (Reference length)
aerosonde.MAC = 0.189941; % m
aerosonde.c=aerosonde.MAC;% 
% Wind span (Reference span)
aerosonde.b = 2.8956; % m
% Wing area (Reference area)
aerosonde.S = 0.55; % m^2

% ALL aerodynamics derivatives are per radian:
%%% Lift coefficient %%%
% Zero-alpha lift
aerosonde.CL0 = 0.23;
% alpha derivative (CLa)
aerosonde.CLalpha = 5.6106;
%CLa=CLalpha
% Lift control (flap) derivative
aerosonde.CLdf = 0.74;
% Pitch control (elevator) derivative
aerosonde.CLde = 0.13;
% alpha-dot derivative
aerosonde.CLalphadot = 1.9724;
% Pitch rate derivative
aerosonde.CLq = 7.9543;
% Mach number derivative
aerosonde.CLM = 0;

%%% Drag coefficient %%%
% Lift at minimum drag
aerosonde.CLmind = 0.23;
% Minimum drag (CDmin)
aerosonde.CD0 = 0.0434;
%CDmin=CD0
% Lift control (flap) derivative
aerosonde.CDdf = 0.1467;
% Pitch control (elevator) derivative
aerosonde.CDde = 0.0135;
% Roll control (aileron) derivative
aerosonde.CDda = 0.0302;
% Yaw control (rudder) derivative
aerosonde.CDdr = 0.0303;
% Mach number derivative
aerosonde.CDM = 0;
% Oswald's coefficient, e
aerosonde.osw = 0.75;
% pieaR, constant = \pi *e *AR where the wing aspect ratio AR=b^2/S
aerosonde.AR = aerosonde.b^2/aerosonde.S;
aerosonde.pieaR = pi*aerosonde.osw* aerosonde.AR;

%%% Side force coefficient %%%
% Sideslip derivative
aerosonde.CYbeta = -0.83;
% Roll control derivative
aerosonde.CYda = -0.075;
% Yaw control derivative
aerosonde.CYdr = 0.1914;
% Roll rate derivative
aerosonde.CYp = 0;
% Yaw rate derivative
aerosonde.CYr = 0;

%%% Pitch moment coefficient %%%
% Zero-alpha pitch
aerosonde.Cm0 = 0.135;
% alpha derivative
aerosonde.Cmalpha = -2.7397;
%Cma = Cmalpha;
% Lift control derivative
aerosonde.Cmdf = 0.0467;
% Pitch control derivative
aerosonde.Cmde = -0.9918;
% alpha_dot derivative
aerosonde.Cmalphadot = -10.3796;
% Pitch rate derivative
aerosonde.Cmq = -38.2067;
% Mach number derivative
aerosonde.CmM = 0;

%%% Roll moment coefficient %%%
% Sideslip derivative
aerosonde.Clbeta = -0.13;
% Roll control derivative
aerosonde.Clda = -0.1695;
% Yaw control derivative
aerosonde.Cldr = 0.0024;
% Roll rate derivative
aerosonde.Clp = -0.5051;
% Yaw rate derivative
aerosonde.Clr = 0.2519;

%%% Yaw moment coefficient %%%
% Sideslip derivative
aerosonde.Cnbeta = 0.0726;
% Roll control derivative
aerosonde.Cnda = 0.0108;
% Yaw control derivative
aerosonde.Cndr = -0.0693;
% Roll rate derivative
aerosonde.Cnp = -0.069;
% Yaw rate derivative
aerosonde.Cnr = -0.0946;


%%% PROPELLER %%%
%Propulsion force application point (usually propeller hub) [x y z]
aerosonde.rHub = [0 0 0]; % m
% Advance ratio vector
aerosonde.J = [-1 0 0.1 0.2 0.3 0.35 0.4 0.45 0.5 0.6 0.7 0.8 0.9 1 1.2 2];
% Coefficient of thrust look-up table CT = CT(J)
aerosonde.CT = [0.0492 0.0286 0.0266 0.0232 0.0343 0.034 0.0372 0.0314 0.0254 0.0117 -0.005 -0.0156 -0.0203 -0.0295 -0.04 -0.1115];
% Coefficient of power look-up table CP = CP(J)
aerosonde.CP = [0.0199 0.0207 0.0191 0.0169 0.0217 0.0223 0.0254 0.0235 0.0212 0.0146 0.0038 -0.005 -0.0097 -0.018 -0.0273 -0.0737];
% Propeller radius
aerosonde.Rprop = 0.254; % m
% Propeller moment of inertia
aerosonde.Jprop = 0.002; % kg*m^2


%%% ENGINE %%%
% Engine rpm vector
aerosonde.RPM = [1500 2100 2800 3500 4500 5100 5500 6000 7000]; % rot per min
% Manifold pressure vector
aerosonde.MAP = [60 70 80 90 92 94 96 98 100]; % kPa
aerosonde.MAPmin = aerosonde.MAP(1); % minimum manifold pressure

% Sea-level fuel flow look-up table fflow = fflow(RPM, MAP)
% RPM -> rows, MAP -> columns
aerosonde.FuelFlow = [
    31 32 46 53 55 57 65 73 82
    40 44 54 69 74 80 92 103 111
    50 63 69 92 95 98 126 145 153
    66 75 87 110 117 127 150 175 190
    83 98 115 143 148 162 191 232 246
    93 102 130 159 167 182 208 260 310
    100 118 137 169 178 190 232 287 313
    104 126 151 184 191 206 253 326 337
    123 144 174 210 217 244 321 400 408
]; % g/hr
% Sea-level power look-up table P = P(RPM, MAP)
% RPM -> rows, MAP -> columns
aerosonde.Power = [
    18.85 47.12 65.97 67.54 69.12 67.54 67.54 69.12 86.39
    59.38 98.96 127.55 149.54 151.74 160.54 178.13 200.12 224.31
    93.83 149.54 187.66 237.5 249.23 255.1 307.88 366.52 398.77
    109.96 161.27 245.57 307.88 326.2 351.86 421.5 491.14 531.45
    164.93 245.04 339.29 438.25 447.68 494.8 565.49 673.87 772.83
    181.58 245.67 389.87 496.69 528.73 571.46 662.25 822.47 993.37
    184.31 293.74 403.17 535.64 570.2 622.04 748.75 956.09 1059.76
    163.36 276.46 420.97 565.49 609.47 691.15 860.8 1130.97 1193.81
    124.62 249.23 417.83 586.43 645.07 762.36 996.93 1246.17 1429.42
]; % W
% Sea-level pressure and temperature at which the data above is given
aerosonde.pSL = 102300; % Pa
aerosonde.TSL = 291.15; % deg K
% Engine shaft moment of inertia
aerosonde.Jeng = 0.0001; % kg*m^2


%%% INERTIA %%%
% Empty aircraft mass (zero-fuel)
aerosonde.mempty = 8.5; % kg
% Gross aircraft mass (full fuel tank)
aerosonde.mgross = 13.5; % kg
% Empty CG location [x y z]
aerosonde.CGempty = [0.156 0 0.079]; % m
% Gross CG location [x y z]
aerosonde.CGgross = [0.159 0 0.090]; % m

% Empty moments of inertia [Jx Jy Jz Jxz]
Jx_empty = 0.7795; % kg*m^2
Jy_empty = 1.122; % kg*m^2
Jz_empty = 1.752; % kg*m^2
Jxz_empty = 0.1211; % kg*m^2
aerosonde.Jempty = [Jx_empty Jy_empty Jz_empty Jxz_empty]; % kg*m^2
% Empty moments of inertia [Jx Jy Jz Jxz]
aerosonde.J_empty = [Jx_empty  0  -Jxz_empty;
           0     Jy_empty       0;
           -Jxz_empty  0  Jz_empty]; % kg*m^2
       
% Gross moments of inertia [Jx Jy Jz Jxz]
Jx_gross = 0.8244; % kg*m^2
Jy_gross = 1.135; % kg*m^2
Jz_gross = 1.759; % kg*m^2
Jxz_gross = 0.1204; % kg*m^2
aerosonde.Jgross = [Jx_gross Jy_gross Jz_gross -Jxz_gross]; % kg*m^2
% Empty moments of inertia [Jx Jy Jz Jxz]
aerosonde.J_gross = [Jx_gross  0  -Jxz_gross;
           0     Jy_gross       0;
           -Jxz_gross  0  Jz_gross]; % kg*m^2

%%% OTHER SIMULATION PARAMETERS %%%
aerosonde.g = 9.81; % m/s^2 gravitational constant

return