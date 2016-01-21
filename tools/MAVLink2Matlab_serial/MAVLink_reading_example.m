clc; clear all; close all
%% MAVLink_Serial Functionalities
MAVLink_functions; % <-- Abrir para aprender como usar esta libreria

%% Example

Vehicle_mat = MAVLink_vehicle_CLASS;  % Build First Vehicle

%Open Serial Connection
comm_channel = 'com4';  % FTDI en Serial 2
baud = 115200;

% comm_channel = 'com11';  % Radio de 3DR
% baud = 57600;

MAVLink_Serial('open', comm_channel, baud);
pause(1)

Vehicle = MAVLink_Serial('readmessage');  % this should see what vehicles are around
% Also clears out buffer
pause(.1)       

% Read only from ONE vehicle
sys_id = Vehicle(1).ID;

%This is new-vehicle conditioning, should be separate new-vehicle
%function to use when running and a new vehicle shows up
MAVLink_Serial('RequestDataStream',sys_id,0,0,0);
pause(1)
MAVLink_Serial('RequestDataStream',sys_id,6,5,1);
pause(1)
MAVLink_Serial('RequestDataStream',sys_id,2,5,1);
pause(1)
MAVLink_Serial('clearmissions',sys_id);

%Now we move first batch of data to our vehicle class, only care
%about location, for the moment
%Copied from Get_Position, might be useful to put into own function
Vehicle_mat.sysid = Vehicle(1).ID; %#ok<*AGROW>

Vehicle = MAVLink_Serial('readmessage'); %clear out anything left in the buffer

MAVLink_Serial('heartbeat');    %Let everyone know we're here
pause(.1)

%% Reading Loop
while 1
    Vehicle = MAVLink_Serial('readmessage');
    Vehicle_mat.latlon = [Vehicle(1).lat/1e7, Vehicle(1).lon/1e7]; % lat and lon from MAVLINK is decimal degrees times 1e7,
    Vehicle_mat.heading = Vehicle(1).hdg/100; % in centidegrees
    Vehicle_mat.alt = Vehicle(1).alt/1e7; % in ??
    Vehicle_mat.roll = Vehicle(1).roll/1e7; % in ??
    Vehicle_mat.pitch = Vehicle(1).pitch/1e7; % in ??
    Vehicle_mat.yaw =  Vehicle(1).yaw/1e7; % in ??
    
    Vehicle_mat
    pause(0.5)
    
    MAVLink_Serial('heartbeat');    %Let everyone know we're here
    pause(.1)
end

MAVLink_Serial('close');


