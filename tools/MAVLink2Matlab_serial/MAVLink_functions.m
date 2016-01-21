%% MAVLink_Serial Functionalities
% MAVLink_Serial('open', comm_channel, baud);
% MAVLink_Serial('ping');
% 
% MAVLink_Serial('RequestDataStream',sys_id,stream_ID,message_rate,start_stop)
%     Stream_ID:
%     0: all
%     1: 27,29 - Raw IMU, Scaled Pressure
%     2: 1,42, 24, 62 - SYS_STATUS, MISSION_CURRENT, GPW_RAW_INT, NAV_CONTROLLER_OUTPUT
%     3: 36, 35 - RC_CHANNELS_RAW, SERVO_OUTPUT_RAW
%     4: 34 - RC_CHANNELS_SCALED
%     5: none
%     6: 33 - GLOBAL_POSITION_INT - Use This One!!!!!!!!!!!
%     7: none
%     8: none
%     9: none
%     10: 30 (attitude)
%     11: 74 (VFR Hud)
%     12: none
%     Message Rate: times per second to transmit data
%     start_stop: 1 for on, 0 for off.
        
% MAVLink_Serial('SetMode',Sys_ID,base_mode,custom_mode); % Set autopilot mode (Auto, manual, etc.)
%     base_mode 
%       Mode, set using bit flags,  4 (00000100) is auto

% MAVLink_Serial('MissionCount',Sys_ID,count); %  MP does this before sending new points

% MAVLink_Serial('MissionItem',Sys_ID,seq,frame,command,current,autocontinue,param1,param2,param3,param4,x,y,z); %  
%     seq: Sequence
%     frame : 0 = Global, 1 = local NED, 2 = Mission (no frame) 3 = Global/relative alt, 4 = local ENU
%     command :/ command number, see MAV_CMD
%     current : is this current mission? 1 = true
%     autocontinue : 1 = true
%     param1: radius of mission item, hor far away is 'reached'
%     param2 : how long to stay inside radius until proceeding (RW only?)
%     param3 : for Loiter - radius to orbit.  positive = CW
%     param4 : Yaw orientation (RW only?)
         
% MAVLink_Serial('missionrequestlist',Sys_ID); %  Send mission request list message asks for list of missions specific requests for mission information need to include which one.

% MAVLink_Serial('missionwritelist',Sys_ID,start_index,end_index); %  Should start by identifying how many things to write, then waiting for response

% MAVLink_Serial('missionrequest',Sys_ID,start_index,sequence); %  Send mission request asks for information on specific mission

% MAVLink_Serial('missioncmd',Sys_ID,command,p1,p2,p3,p4,p5,p7); %  This currently uses the _command_long_ message to send a command  Any command is possible, I built for NAV_WAYPOINT, which is 16

% MAVLink_Serial('heartbeat'); %  Send heartbeat message

% MAVLink_Serial('clearmissions',Sys_ID); %  

% MAVLink_Serial('changecontrol',Sys_ID); %  

% MAVLink_Serial('readallparams',Sys_ID); %  

% MAVLink_Serial('close'); %  

% MAVLink_Serial('clearRX'); %  

% MAVLink_Serial('readmessage'); %  This is the one that actually reads   info from MAVLink
