%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Uses MAVLINK to communicate with 4 aircraft
%   User selects points (single-click) or areas(click-and-drag).  Program
%   converts to point tasks or line tasks and assigns to vehicles.
%
%   Updated with aerial image of test field near Lake Wheeler
%
%   Coded by Chad Bieber
%   March 2014
%
% WARNING: Selecting points outside of environment boundary result in
% incomplete path matrices, which will crash
%   Attempted to access A.path(2,:); index out of bounds because size(A.path)=[1,2].
%
% Notes: The Get_Position function fails when no vehicles are transmitting
% (matrix assignment size mismatch).  Should fool-proof, current
% work-around is not to run before an aircraft is transmitting.
%
% Mouse-click position conversion clunky/shoddy.  Should find correct conversion
%
% Not using path when executing line task.  Could add multiple points to
% end of path to keep vehilcle on track instead of flying straight to second
% point.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function GUI_with_image()
clc; clear all; close all

%Build Structures
World = struct('N', 1100, ...   %Window Size
    'M', 800, ...
    'X', 150, ...     %graph size
    'Y', 75, ...
    'Z', 25, ...
    'BoundaryX', [], ... For frame/border edge
    'BoundaryY', [], ...
    'BoundaryZ', []);

times = struct('BeginTime', 0,...       %holds time at beginning of simulation - not used, I think
    'deltat', .5, ...           %loop time steps
    'completion', 0, ... % calculated time remaining for assigned tasks
    'current', 0);       % used for history

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initialize Variables.
%
%Nested Functions can share variables, but can't make new ones in the
%workspace that weren't initialized in parent function.  Initialization can
%be empty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ButtonDown = 0; distance = [];
mouse_start = [];
%Robustness constant for path finding function shortest_path -
%NOTE: dubins also uses an epsilon.  They are different, and should
%be changed
epsilon = 0.0000000001;

%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)FA(
snap_distance = 0.05;
%Build World_Frame border
World.BoundaryX = [0 0 0 0 0 0 0 0 1 1 1 1
    0 0 0 0 1 1 1 1 1 1 1 1];
World.BoundaryY = [0 0 0 1 0 0 1 1 0 0 0 1
    0 1 1 1 0 0 1 1 0 1 1 1];
% World.BoundaryZ = [0 0 1 0 0 1 0 1 0 0 1 0;
%                    1 0 1 1 0 1 0 1 1 0 1 1];

World.BoundaryX = World.X*World.BoundaryX;
World.BoundaryY = World.Y*World.BoundaryY;
tasks = [];
new_task = 0;
completed_task = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Testing image loading.  See drawnow
%Needs image already in folder!!!!!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sat_image = imread('lake_wheeler4.jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These govern which geographic area is plotted on the screen and how big
% it is.  Should move to GUI for in-program editing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scaling = 10; %scaling factor, converts meters in Lat/Lon to screen units (what units?)

%This is left and right points for baseline, used in both conversion
% functions, so put here
% left_point = [40.17170,-76.55910];  %Greentree & e-town roan
% right_point = [40.17224, -76.55741]; %original
% left_point = [40.17228,-76.55920];  %Greentree & e-town roan
% right_point = [40.17133, -76.55898]; %rotated?
%         left_point = [40.14496,-76.5988];% S. Hanover St.
%         right_point = [40.14460, -76.59862];
%         left_point = [35.76865,-78.66421]; % Dorothea Dix
% left_point = [35.727118,-78.6944246];  %Lake Wheeler Ag
% right_point = [35.72710, -78.69614]; %
left_point = [35.729030,-78.688590];  %Lake Wheeler Ag, bigger to match pic
right_point = [35.728718, -78.703867]; %

% left_point = [35.7705417,-78.6740613];  %EB III
% right_point = [35.7713162, -78.6733639]; %


%Make a north-pointer - can use to point north, or to get bearings?
%Decided not to.  For bearing-dist purposes, can convert bearing-distance
%to lat-lon, add to left point (zero coordinate), then LL2Loc convert to
%location-distance.

%Build Vehicles
A(1) = MAVLink_vehicle_CLASS;           %      Build First Vehicle
id2index = [0;0;0;0];        %id2index(sysid) = A_index  -- not automatic, update when add vehicles
Home = [55 30;  70 30; 55 45; 70 45];  %home loiter position, should be in struct, and should change based on number of vehicles
colors = ['r' 'g' 'm' 'b'];
Min_Volts = 10;

Cruise_Alt = 60; %Standard altitude in meters
Home_Alt = Cruise_Alt + 5; %for easy separation from tasked aircraft
swathwidth = 60; %how far apart line tasks are
close_enough = 30; %how close to get to arrive at point
mission_radius = 1; %not using mavlink's mission reached notification
home_loiter_radius = 30; %Radius in meters to loiter, in mission item command package
task_loiter_radius = 1; %I don't actually want them to loiter, I want them to move to next point


%Build Obstacles
obstacles = [100 40];  %lower left corner - add more rows for more obstacles
obstacle_sizes = [49 34]; %length of x and y sides, add more rows for more obstacles
%  obstacles = 0;
environment_generator();

%This function builds window and graphics properties
handles = set_figure_properties(World, times);

drawnow


% Popup message to connect airplane and enter baud/com
uiwait(msgbox('Please ensure at least one aircraft is powered on', 'Ready Aircraft', 'modal'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Set initial conditions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Open Serial Connection
% comm_channel = 'com7';  % these are for USB connect on desktop
% baud = 1;

%  comm_channel = 'com9';  %these are for other USB to xbee on desktop
%  baud = 57600;
%  comm_channel = 'com3';  %these are for left USB to xbee connect on laptop
%  baud = 57600;
% comm_channel = 'com4'  % these are for xbee link on desktop or right USB on laptop
% baud = 57600;


comm_channel = 'com4'  % these are for xbee link on desktop or right USB on laptop
baud = 115200;


%
prompt = {'Enter comm channel:','Enter baud:'};
dlg_title = 'Input';
num_lines = 1;
baud_string = num2str(baud);
def = {comm_channel,baud_string};
user_input = inputdlg(prompt,dlg_title,num_lines,def);

comm_channel = user_input{1};
baud = str2double(user_input{2});

MAVLink_Serial('open', comm_channel, baud);
pause(1)

Vehicle = MAVLink_Serial('readmessage');  % this should see what vehicles are around
% Also clears out buffer
pause(.1)                       % Wait a moment
Incoming_IDs = zeros(1,5);
for c=1:5 %this is current size of Vehicle output from readmessage
    if (~isempty(Vehicle(c).ID)) %If the ID is not empty
        Incoming_IDs(c) = Vehicle(c).ID;
    else Incoming_IDs(c) = 0;   %If ID is empty, set to zero to maintain indices
    end %if not empty
end %for k
id_index = find(Incoming_IDs); %this is index of each ID - should just be 1,2, etc unless there was a gap or zero in the list
num_ids = size(id_index,2); %This is how many non-zero IDs, will return zero if id_index is empty


for b = 1:num_ids  %this could be zero, but for 1 = 1:0 doesn't break.  Shouldn't be [], size([]) is zero
    sys_id = Incoming_IDs(b);
    
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
    A(b).sysid = Vehicle(b).ID; %#ok<*AGROW>
    % put sysids into id2index matrix,
    id2index(A(b).sysid) = b;
    
    if(~isempty(Vehicle(b).lat) && Vehicle(b).lat ~= 0) % If no location message was read, returns empty values
        A(b).latlon = [Vehicle(b).lat/1e7, Vehicle(b).lon/1e7]; % lat and lon from MAVLINK is decimal degrees times 1e7,

        loc_update = ll2loc(A(b).latlon(1), A(b).latlon(2));
        A(b).location = loc_update;
    end % if ~empty
    
end
Vehicle = MAVLink_Serial('readmessage'); %clear out anything left in the buffer

MAVLink_Serial('heartbeat');    %Let everyone know we're here
pause(.1)

% %Build initial tasks
% rectangle = [5 20 15 20];
% tasks = CutSwaths(rectangle, 3);

times.BeginTime = tic;
%open log file, overwrite on
time = clock;
Year = num2str(time(1));
Month = num2str(time(2));
Day = num2str(time(3));
Hour = num2str(time(4));
Minute = num2str(time(5));
filename = strcat('.\Logs\flightlog', Year, Month, Day, Hour, Minute, '.txt')

fileID = fopen(filename, 'w');
%Write data headers for vehicles
fprintf(fileID,'Vehicle column headers \n');
fprintf(fileID,'sysid location heading altitude latlon task voltage active \n');
fprintf(fileID,'Task column headers\n');
fprintf(fileID,'x1 y1 x2 y2\n');
start(handles.Loop_Timer);    % start timer


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Callbacks
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Simulation_Callback oversees the simulation, conditions the route by
%subtracting passed over points and adding points when no instructions are
%given.  Calls TimingPath and drawtimingsphere.




    function Simulation_Callback(~,~)
        MAVLink_Serial('heartbeat'); % Send heartbeat message
        
        if new_task % Re-assign tasks and send task assignments if task added
            Assign_Tasks()
            Send_Tasks() %This sends task assignments to vehicles via MAVLINK
        end
        Get_Positions() %This gets current positions from vehicles using MAVLINK
        % one of the functions was altering i, couldn't track down, used p
        for p = 1:size(A,2)     %At each time step, cycle through vehicles
            % Move not needed with real vehicles
            %             A(p) = move(A(p),times.deltat);     %Move
            
            if A(p).assigned && A(p).active      %if tasked, check if close to task
                next = A(p).path(A(p).current_path,:);
                if A(p).executing %If executing a line task -- the straight if, rather than if == 1, will throw true on 2 also
                    next = A(p).task(3:4); %The check distance is to last point
                end
                tgt_dist = howfar(A(p).location, next);
                if tgt_dist < close_enough/scaling
                    if A(p).current_path < size(A(p).path,1) %if we aren't at the end
                        
                        A(p).current_path = A(p).current_path+1; %Go to the next point in the path
                        
                    else %we're at the end!  Everbody Re-assign!
                        
                        
                        % do if point task, then else for lines.  Otherwise,
                        % can't do matrix boolean ~=, have to do number by number
                        % because line tasks are always horiz or vert, and one
                        % pair of numbers always match
                        if A(p).task(1:2) == A(p).task(3:4) %If point ask
                            A(p).assigned = 0;      %unassign and delete task
                            completed_task = [completed_task; A(p).task];
                            A(p).task = [];
                            %Add something here to keep
                            %track of completed tasks
                            Assign_Tasks()      %assign tasks
                            Send_Tasks() %This sends task assignments to vehicles via MAVLINK
                            
                        else %Not a point task, must be line task!
                            if A(p).executing == 0 %first time we got here
                                A(p).executing = 1;
                                Send_Tasks() %This sends task assignments to vehicles via MAVLINK
                                
                                
                                %sometimes, the next cycle eats the point
                                %just assigned.
                                %Hypothesis: the distance to
                                %target is being read from a transmission
                                %sent before the reassignment.
                                %Experiment: add another cycle, to clear any
                                %messages sent out of the buffer.
                                A(p).executing = 2;
                            elseif A(p).executing == 2;
                                %Now, we go back to
                                A(p).executing = 1; %Start executing the task!
                                
                                % Send_Tasks function will send appropriate task based
                                % on executing flag
                                Send_Tasks() %This sends task assignments to vehicles via MAVLINK
                                
                            elseif A(p).executing == 1 %If we are already executing, then we finished!  Everybody Reassign!
                                A(p).executing = 0; %Vehicle has completed line task
                                A(p).assigned = 0;      %unassign
                                completed_task = A(p).task; %Move task to completed list.  Hmmm, not listing?
                                A(p).task = [];  %delete task
                                Assign_Tasks()      %assign tasks
                                Send_Tasks() %This sends task assignments to vehicles via MAVLINK
                            else %shouldn't get here
                                % default should throw error
                            end %if executing
                            
                        end
                    end
                    
                else %if not close enough, check that we are pointed to the right task
                    %if where the computer thinks we're going and where the
                    %plane thinks we're going is more than 10 meters off
                    if abs(tgt_dist*scaling - A(p).target_distance) > 10
                        Send_Tasks() %then remind the plane where to go
                    end
                end %close enough
                
                
                % Check for point task, then else for lines.  Otherwise,
                % can't do matrix, have to do number by number
                % because line tasks are always horiz or vert, and one
                %                    % pair of numbers always match
                %                        if A(p).task(1:2) == A(p).task(3:4) %If point ask
                %
                %                        else % if not a point task, then send down the line
                %
                %                            if A(p).executing == 0
                %
                %                                tgt_dist = howfar(A(p).location, A(p).task(1:2));
                %
                %                                if tgt_dist <= 25/scaling
                %                                    A(p).executing = 1; %identify that vehicle is on a line task, should not be re-assigned
                %
                %                    % Send_Tasks function will send appropriate task based
                %                    % on executing flag
                %
                %                                     Send_Tasks() %This sends task assignments to vehicles via MAVLINK
                %
                %                                end % if close enough
                %
                %                            elseif A(p).executing == 1 %If the vehicle is executing
                %
                %                                tgt_dist = howfar(A(p).location, A(p).task(3:4)); %check distance to second point
                %
                %                                if tgt_dist <= 25/scaling
                %
                %                                    A(p).executing = 0; %Vehicle has completed line task
                %                                    A(p).assigned = 0;      %unassign
                %                                    completed_task = A(p).task; %Move task to completed list.  Hmmm, not listing?
                %                                    A(p).task = [];  %delete task
                %                                    Assign_Tasks()      %assign tasks
                %                                    Send_Tasks() %This sends task assignments to vehicles via MAVLINK
                %                                end % if close enough
                %                                else
                %                                    % default should throw error
                %                            end %if executing
                %
                %
                %
                %                        end %if line task, else
                %whether moving to next point in line or
                %assigning, tasks are sent
                
                
            else %if not assigned
                if ~isempty(tasks)  %and tasks exist
                    Assign_Tasks()      %assign tasks
                    Send_Tasks() %This sends task assignments to vehicles via MAVLINK
                    
                elseif A(p).active %if no tasks and active
                    Go_Home(p) %go home
                end %if tasks exist
            end
            if(A(p).assigned && A(p).active)  %second identical - merge?  Or does this let new assignments be drawn immediately?
                path_line = 0; %This turns the plotted path on or off
                if path_line
                    next_point = A(p).path(2,:);
                    A(p).d_path = dubinspath(A(p).location, A(p).heading, ...
                        next_point, A(p).turn_radius);
                end %if path_line
            end %if assigned
            
        end %for n of vehicles
        drawenvironment()
        drawnow
        write_history()
    end %simulation callback


    function write_history()
        % this function records system data at each time step for post
        % analysis
        times.current = toc(times.BeginTime);
        
        fprintf(fileID,'time: %f \n', times.current);
        
        fprintf(fileID,'number of vehicles: %d \n', size(A,2));
        
        %things to save
        for i = 1:size(A,2)
            x = 0; y = 0; alt = 0; lat = 0; lon = 0;
            task1 = 0; task2 = 0; task3 = 0; task4 = 0;
            volts = 0; heading = 0;
            if ~isempty(A(i).location)
                x = A(i).location(1);
                y = A(i).location(2);
            end %if location
            if ~isempty(A(i).heading)
                heading = A(i).heading;
            end %heading
            if ~isempty(A(i).alt)
                alt = A(i).alt;
            end %if alt
            
            if ~isempty(A(i).latlon)
                lat = A(i).latlon(1);
                lon = A(i).latlon(2);
            end %if latlon
            if ~isempty(A(i).task)
                task1 = A(i).task(1);
                task2 = A(i).task(2);
                task3 = A(i).task(3);
                task4 = A(i).task(4);
            end %if tasked
            if ~isempty(A(i).voltage);
                volts = A(i).voltage;
            end %if tasked
            
            fprintf(fileID,'%d, %f, %f, %01f, %d, %f, %f, %f, %f, %f, %f, %01.2f, %d \n', ...
                A(i).sysid, x, y, heading, alt, lat, lon, task1, task2, task3, task4, volts, A(i).active);
        end
        if ~isempty(tasks)
            fprintf(fileID, 'number of tasks: %d \n', size(tasks,1));
            for i = 1:size(tasks,1)
                fprintf(fileID, '%f, %f, %f, %f \n', tasks(i,1), tasks(i,2), tasks(i,3), tasks(i,4));
            end %for
        end %if tasks
    end %write history



    function Balloon_Figure_Delete_Function(~, ~)
        
        %         MAVLink_Serial('close'); %Close serial port - don't need, mex at
        %         exit does it for us
        fclose(fileID);
        stop(handles.Loop_Timer)
        delete(handles.Loop_Timer)
        clear A                             %Clear open objects, easier way?
    end %Delete Function

    function pushbutton_reset_tasks_callback(~, ~)
        for i = 1:size(A,2)
            A(i).task = [];
            A(i).assigned = 0;
            A(i).executing = 0;
        end %for
        tasks = [];
    end %Reset Button



    function [lat,lon] = loc2ll(location)
        base_vector = right_point - left_point;
        lat2meters = 111000; lon2meters = 85200;
        base_meters = base_vector.*[lat2meters, lon2meters];
        %         length = sqrt((base_meters(1))^2+(base_meters(2))^2);
        theta = atan2(base_meters(2), base_meters(1));
        location2latlon_matrix = [cos(theta) sin(theta);sin(theta) -cos(theta)];
        
        location  = location*scaling; %Scaling factor,  divisor in other conversion
        latlon_meters = location*location2latlon_matrix;
        latlon = latlon_meters.*[1/lat2meters 1/lon2meters] + left_point;
        lat = latlon(1);
        lon = latlon(2);
        
        
    end % loc2latlon

    function [location] = ll2loc(lat,lon)
        base_vector = (right_point - left_point);
        lat2meters = 111000; lon2meters = 85200;
        base_meters = base_vector.*[lat2meters, lon2meters];
        %         length = sqrt((base_meters(1))^2+(base_meters(2))^2);
        theta = atan2(base_meters(2), base_meters(1));
        latlon2location_matrix = [cos(theta) sin(theta);sin(theta) -cos(theta)];
        
        latlon_meters = ([lat lon]-left_point).*[lat2meters lon2meters];
        location = latlon_meters*latlon2location_matrix;
        %         location(2) = -location(2); %HACK!  fix math
        location = location/scaling; %Scaling factor, make more elegant.
        
    end % loc2latlon

% This function calculates distance between two points in screen-meters
% (location) coordinates.  Distance is always positive, order of points
% does not matter
    function [d] = howfar(point1, point2)
        d = sqrt((point1(1)-point2(1))^2+(point1(2)-point2(2))^2);
    end % howfar


    function Send_Tasks() %Sends task assignments to vehicles
        for p = 1:size(A,2)
            
            %             if ~isempty(A(p).task) && A(p).active % if tasked and active
            %                 [lat1, lon1] = loc2ll(A(p).task(1:2));
            %                 [lat2,lon2] = loc2ll(A(p).task(3:4));
            
            
            if ~isempty(A(p).path) && A(p).active % if tasked and active
                pause(.1)
                
                % Guided mode uses a waypoint sent with current flag set to 2.
                % This should cause the plane to fly directly towards this
                % point, and then orbit when it gets there.
                
                if A(p).executing % if executing a line task, go to second point in line
                    
                    [lat2,lon2] = loc2ll(A(p).task(3:4)); %This is second point n task, for use if executing line task
                    
                    for z = 1:3
                        MAVLink_Serial('MissionItem',...
                            A(p).sysid, ... %system id
                            1, ...  %Sequence, first is 0
                            3, ...  %Frame, 3 is Global lat/lon, relative alt
                            16,...  %command, 16 is fly to, 17 is loiter unlimited
                            2, ...  %current = 2 is "guided" mode in APM
                            1, ...  %autocontinue = true
                            mission_radius, ...  % Radius of mission item
                            0, task_loiter_radius, 0, ... %how long to loiter, loiter radius, yaw
                            lat2, ... %x position - not in lat/lon yet
                            lon2, ... %y position, not in lat/lon yet
                            Cruise_Alt);    %   Altitude, relative to initial position
                    end
                else % if not executing, go to first point
                    A(p).path
                    A(p).current_path
                    next_point = A(p).path(A(p).current_path,:);
                    [lat1, lon1] = loc2ll(next_point); %this is next point in path
                    
                    for z = 1:3
                        MAVLink_Serial('MissionItem',...
                            A(p).sysid, ... %system id
                            1, ...  %Sequence, first is 0
                            3, ...  %Frame, 3 is Global lat/lon, relative alt
                            16,...  %command, 16 is fly to, 17 is loiter unlimited
                            2, ...  %current = 2 is "guided" mode in APM
                            1, ...  %autocontinue = true
                            mission_radius, ...  % Radius of mission item
                            0, task_loiter_radius, 0, ... %how long to loiter, loiter radius, yaw
                            lat1, ... %x position - not in lat/lon yet
                            lon1, ... %y position, not in lat/lon yet
                            Cruise_Alt);    %   Altitude, relative to initial position
                    end
                end
                
            elseif A(p).active% %If no task and active, go home
                Go_Home(p)
            else
                %if not active, do nothing
            end %if task, else
            
            
        end %for
    end %Sen Tasks

    function Go_Home(index) %Sends vehicle to designated wait position to loiter
        [lat1, lon1] = loc2ll(Home(A(index).sysid,:));
        
        
        % Guided mode uses a waypoint sent with current flag set to 2.
        % This should cause the plane to fly directly towards this
        % point, and then orbit when it gets there.
        MAVLink_Serial('MissionItem',...
            A(index).sysid, ...     % System ID
            1, ...  %Sequence, first is 0
            3, ...  %Frame, 3 is Global lat/lon, relative alt
            16,...  %command, 16 is fly to, 17 is loiter unlimited
            2, ...  %current = 2 is "guided" mode in APM
            1, ...  %autocontinue = true
            mission_radius, ...  % Radius of mission item
            0, home_loiter_radius, 0, ... %how long to loiter, loiter radius, yaw
            lat1, ... %x position - not in lat/lon yet
            lon1, ... %y position, not in lat/lon yet
            Home_Alt);    %   Altitude, relative to initial position
        
        
    end % Go Home


    function Get_Positions()
        
        Vehicle = MAVLink_Serial('readmessage'); %Vehicle is 5-wide struct
        ID = [];
        sysid = [];
        
        for k=1:size(Vehicle,2)
            if (~isempty(Vehicle(k).ID))
                ID(k) = Vehicle(k).ID;
            end %if isempty
        end %for
        
        for j=1:size(A,2)
            if (~isempty(A(j).sysid))
                sysid(j) = A(j).sysid;
            end %if not empty
        end %for
        %ID is transmitted with all messages, use to identify if new
        %information available
        if (~isempty(ID)) % Don't check to see if empty things are there.
            ID = ID(ID~=0); %this removes zeroes, which should be all trailing
            [tf,~] = ismember(ID,sysid);
            [new_vehicle, new_index] = ismember(0,tf); %this will be true
            
            
            
            if (new_vehicle) % we have a new vehicle!  WARNING!!! Only sees one new vehicle at a time
                pause(.01)
                new_A_index = size(A,2)+1;
                new_id = Vehicle(new_index).ID;
                A(new_A_index).sysid = new_id;
                id2index(new_id) = new_A_index;
                
                %Now, pull sysid again
                for j=1:size(A,2)
                    A(j).sysid
                    sysid(j) = A(j).sysid;
                end %for
                
            end % if new vehicle
            
            
        end %if not empty
        [tf,index] = ismember(sysid,ID); %This lets me go through size A, instead of size Vehicles
        % it might take care of
        % removing zeroes earlier
        
        if(tf) % only cycle through if there was a match
            for l = 1:size(A,2)
                % Don't use lat lon if the value is empty or zero - Empty if no
                % location message read, zero if no GPS lock yet
                if(~isempty(Vehicle(index(l)).lat) && Vehicle(index(l)).lat ~= 0) % If no location message was read, returns empty values
                    A(l).latlon = [Vehicle(index(l)).lat/1e7, Vehicle(index(l)).lon/1e7]; % lat and lon from MAVLINK is decimal degrees times 1e7,
                    loc_update = ll2loc(A(l).latlon(1), A(l).latlon(2));
                    A(l).location = loc_update;
                    A(l).heading = Vehicle(index(l)).hdg/100; %in centidegrees
                    %this was clodged fix for indoor testing, removing
                    %shouldn't change real world
                    %             elseif Vehicle(index(l)).lat==0
                    %                  A(l).latlon = left_point; % lat and lon from MAVLINK is decimal degrees times 1e7,
                    %                 loc_update = ll2loc(A(l).latlon(1), A(l).latlon(2));
                    %                 A(l).location = loc_update;
                    %                 A(l).heading = Vehicle(index(l)).hdg/100; %in centidegrees
                    %                 Vehicle(index(l)).lat = left_point(1);
                    %                 Vehicle(index(l)).lon = left_point(2);
                end % if
                %check if nav controller message received
                if(~isempty(Vehicle(index(l)).target_distance) && Vehicle(index(l)).target_distance ~= 0) % If no location message was read, returns empty values
                    A(l).target_distance = Vehicle(index(l)).target_distance;
                    A(l).target_bearing = Vehicle(index(l)).target_bearing;
                    A(l).nav_bearing = Vehicle(index(l)).nav_bearing;
                    A(l).alt = Vehicle(index(l)).alt;
                    
                    
                    
                end % if
                
                %Location if above doesn't run if location is zero - hard to
                %test indoors
                Update_Vehicle_Status(Vehicle(index(l)))
                
                
            end     % for A
        end % if tf
    end % Get Position


    function Assign_Tasks()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        
        
        %This first section where vehicles are unassigned was inside a
        %new_task if.  Moved here to re-assign all vehicles for every
        %assignment.
        %This task happens inside a loop using i as a counter, can't use i in this
        %function
        
        new_task = 0;
        for j = 1:size(A,2)     %run through vehicles
            if ~A(j).executing  %if the vehicle is not executing a task
                %Doesn't check if vehicle active, because
                %need to release tasks from inactive
                %vehicles too
                tasks = [tasks; A(j).task];  %Put current task back in basket
                A(j).task = [];             %Clear task
                A(j).assigned = 0;          %unassign
            end
        end
        
        
        for j = 1:size(A,2)
            %Build list of unassigned and active vehicles
            unassigned_vehicles(j) = ~A(j).assigned & A(j).active;
            
        end
        
        unassigned_vehicles = find(unassigned_vehicles); %returns indices of non-zeros
        
        %unassigned vehicles is now list of indexed positions of
        %vehicles without assignment in A structure.
        
        if ~isempty(unassigned_vehicles) %If there are some unassigned vehicles
            environment = read_vertices_from_file('./test.environment');
            for i = 1:size(unassigned_vehicles,2)
                %                 if ~isempty(A(i).path)  %I don't know what this part
                %                 does.
                %                 path_point = A(i).path(1,:);
                %                 point = path_point{1};
                %                 end
                %
                
                m = size(tasks,1);
                for j = 1:m
                    vehicle_x = A(unassigned_vehicles(i)).location(1);
                    vehicle_y = A(unassigned_vehicles(i)).location(2);
                    task_x = tasks(j,1);
                    task_y = tasks(j,2);
                    my_path{1} = shortest_path( [vehicle_x, vehicle_y] , [task_x, task_y] , ...
                        environment, epsilon, snap_distance );
                    path1 = (my_path);
                    route_x = my_path{1}(:,1);
                    route_y = my_path{1}(:,2);
                    path_length = 0;
                    for k = 1:size(route_x,1)-1
                        path_length = path_length + ...
                            sqrt((route_x(k) - route_x(k+1))^2 + ...
                            (route_y(k) - route_y(k+1))^2);
                    end
                    dist1 = path_length;
                    
                    %line(route_x,route_y)
                    %line(route_x,route_y,'Color',colors(i*step,:))
                    
                    if tasks(j,1:2) == tasks(j,3:4) % This returns matrix, I believe the If only goes if both are positive
                        %if point, weight second distance as infinite
                        dist2 = inf;
                        path2 = cell(size(path1));
                    else
                        %if line, add second distance and turn weight
                        task_x = tasks(j,3);
                        task_y = tasks(j,4);
                        
                        my_path{1} = shortest_path( [vehicle_x, vehicle_y] , [task_x, task_y] , ...
                            environment, epsilon, snap_distance );
                        
                        path2 = (my_path);
                        route_x = my_path{1}(:,1);
                        route_y = my_path{1}(:,2);
                        path_length = 0;
                        
                        for l = 1:size(route_x,1)-1
                            path_length = path_length + ...
                                sqrt((route_x(l) - route_x(l+1))^2 + ...   %CHECK - this really doesn't look like it is checking the other end of the task
                                (route_y(l) - route_y(l+1))^2);
                        end
                        dist2 = path_length;
                    end
                    
                    %This builds a distance matrix to the shorter of the
                    %two task ends.  It does not differentiate, here, which
                    %end is which, must do that at assignment.
                    dist = [dist1;dist2];
                    p = [path1;path2];
                    [distance(j,i),I] = min(dist);
                    paths{unassigned_vehicles(i),j} = p(I);
                    dist = []; %#ok<NASGU> clearing variable for next round
                    p = []; %#ok<NASGU> clearing variable for next round
                    
                end %tasks
            end    %unassigned_vehicles
            
            
            
            
            
            assignment_method = 'hungarian';
            switch assignment_method
                case 'greedy'
                    [~,I] = min(distance);
                    
                    n_veh = size(unassigned_vehicles,2);
                    n_task = size(tasks,1);
                    
                    for i = 1:min(n_veh,n_task)     %Use smaller of vehicles or tasks
                        %this series identifies the Vehicle from the indice
                        %recorded in unassigned_vehicles
                        index = I(i);
                        
                        A(unassigned_vehicles(i)).task = tasks(index,:);
                        tasks(index,:) = zeros;
                        A(unassigned_vehicles(i)).assigned = 1;
                    end
                    
                    tasks(~any(tasks,2),:) = [];        %Delete zerod rows
                    distance = [];  %Empty distances
                case 'hungarian'
                    %should edit distance matrix to not include unassigned vehicles
                    %scratch that, I'm pretty sure distance matrix doesn't include
                    %unassigned
                    
                    [assignment, ~] = assignmentoptimal(distance);
                    %assignement vector is list of tasks and the vehicle that has been
                    %assigned to them, referenced using the index of the unassigned_vehicles
                    %list.  This is a bit convoluted, because the unassigned_vehicles list
                    %contains the reference indices of the vehicles from A that are not
                    %assigned.
                    
                    for i = 1:size(assignment,1)
                        if ~assignment(i)==0
                            vehicle_index = unassigned_vehicles(assignment(i));
                            task_index = i;
                            
                            %Here, the vehicle is identified by the index recorded in
                            %unassigned_vehicles as referenced by the point in the
                            %assignment vector
                            this_path = paths{vehicle_index,task_index}; %this is cell, size 1.  A matrix is easier to deal with
                            A(vehicle_index).path = this_path{1}; % assign just the contents of the cell to the vehicle path
                            A(vehicle_index).current_path = 2; %starts with second point, first is location of vehicle
                            
                            if tasks(i,1:2) == tasks(i,3:4)
                                
                                A(vehicle_index).task = tasks(task_index,:);
                            else
                                
                                %calculate_distance was using a dubin's
                                %path method with turn radius to choose
                                %which end was closer.  Possibly the cause
                                %of cycling problems, since that
                                %distance-to uses only straight line.
                                
                                %                                 [dist1, dist2] = calculate_distance(vehicle_index, task_index);
                                
                                dist1 = howfar(A(vehicle_index).location, tasks(task_index,1:2));
                                dist2 = howfar(A(vehicle_index).location, tasks(task_index,3:4));
                                
                                if dist1 > dist2
                                    A(vehicle_index).task =  [tasks(task_index,3:4), tasks(task_index,1:2)];
                                else
                                    A(vehicle_index).task = tasks(task_index,:);
                                end
                                
                            end
                            A(vehicle_index).assigned = 1;
                            tasks(task_index,:) = zeros;      %zero, don't delete yet, deleting alters matrix size
                        end % if ~assignmend
                        
                    end %for size assignment
                    
                    tasks(~any(tasks,2),:) = [];        %Delete zerod rows
                    
                    distance = [];  %Empty distances
                    
            end % switch
        end % if unassigned not empty
    end % Assign_Tasks function



% New Point input box - used now to input two points defining corners of a
% rectangle
    function Edit_new_point_Callback(~, ~)
        
        handles.text1 = get(handles.edit_new_point, 'string');
        InputCorners = str2num(handles.text1); %#ok<ST2NM> expected array input
        
        %check for proper input size
        if size(InputCorners,2) == 3 && size(InputCorners,1) ==2
            
            
        else
            display 'error: wrong size input.  Please enter a 2 by 2 position array'
            
        end
    end %Edit text box





    function Balloon_Figure_MotionFcn(~, ~)
        %         Window_Position = get(handles.balloon_axes, 'position');
        %         WindowSize = Window_Position(3:4);
        
        if ButtonDown
            
            %get position of mouse
            mouse_pos = get(handles.Balloon_Figure,'CurrentPoint');
            %Check to see if mouse is in balloon window
            if mouse_pos(1) >= (10) &&...
                    mouse_pos(1) <= (World.N-310) &&...
                    mouse_pos(2) >= (10) &&...
                    mouse_pos(2) <= (World.M-20)
                
            else
                %put other mouse-click functions here
            end
            
        else
            %default?
        end
    end %Mouse Motion



    function Balloon_Figure_ButtonDownFcn(~, ~)
        mouse_pos = get(handles.Balloon_Figure, 'currentPoint');
        
        if mouse_pos(1) >= (10)             &&...
                mouse_pos(1) <= (World.N-310)    &&...
                mouse_pos(2) >= (10)             &&...
                mouse_pos(2) <= (World.M-20)
            
            ButtonDown = 1;
            correctedX=(mouse_pos(1)-47-10);       %correction factor determined from clicking on screen
            correctedY=(mouse_pos(2)-225);      %same  Also, denominator in other correction
            correctionX = (World.X)/(696);
            correctionY = (World.Y)/(348);
            
            correctedX = correctedX*correctionX;
            correctedY = correctedY*correctionY;
            
            %             defaultZ = 12.5;
            mouse_start = [correctedX correctedY];
            %             click_position = [correctedX correctedY defaultZ correctedX correctedY defaultZ]; %New point goes in twice for point task
            %             latlon_string = num2str([correctedX correctedY])
            %             handles
            %             set(handles.display_location,'String',latlon_string);
        else
            %put other mouse-click functions here
        end
    end %Mouse click down



    function Balloon_Figure_ButtonUpFcn(~, ~)
        mouse_pos = get(handles.Balloon_Figure, 'currentPoint');
        
        
        
        if (mouse_pos(1) >= (10)            &&... %If up click happened in world
                mouse_pos(1) <= (World.N-310)    &&...
                mouse_pos(2) >= (10)             &&...
                mouse_pos(2) <= (World.M-20)     && ...
                ButtonDown)                           %And the down click happened in world
            
            
            correctedX=(mouse_pos(1) - 47-10);       %correction factor determined from clicking on screen
            correctedY=(mouse_pos(2) - 225);        %same  Also, denominator in other correction
            correctionX = (World.X)/(696);      %denominator experimentally derived from clicking on screen
            correctionY = (World.Y)/(348);      % Same.  How to know in advance?
            
            correctedX = correctedX*correctionX;  %Used to Snap to whole numbers, add round back to do so again
            correctedY = correctedY*correctionY;
            
            defaultZ = 12.5;                                %Add Z
            mouse_end = [correctedX correctedY defaultZ];
            [mouselat, mouselon] = loc2ll([correctedX correctedY]);
            latlon_string = num2str([mouselat, mouselon],' %2.6f ');
            set(handles.display_lat_lon,'string',latlon_string);
            location_string = num2str([correctedX, correctedY]);
            set(handles.display_location,'string',location_string);
            
            
            maxWidth = 3;
            
            if (abs(mouse_start(1)-mouse_end(1)) > maxWidth && ...   %If mouse movement describes a rectangle
                    abs(mouse_start(2)-mouse_end(2)) > maxWidth)          % Don't do just straight-line distance, needs non-zero width and height
                
                x1 = mouse_start(1); y1 = mouse_start(2);
                x2 = mouse_end(1); y2 = mouse_end(2);
                x = min(x1, x2); y = min(y1, y2);
                w = abs(mouse_start(1) - mouse_end(1)); h = abs(mouse_start(2) - mouse_end(2));
                rectangle = [x y w h];
                InputTasks = CutSwaths(rectangle, swathwidth/scaling);
                tasks = [tasks; InputTasks(:,:)];
                new_task = 1;
                
                
            else          %If mouse did not move substantially
                %                 if Launch
                %                     %launch new vehicle
                %                     n = size(A,2);      %How many vehicles already?
                %                     A(n+1) = MAVLink_vehicle_CLASS();           % Build one more vehicle
                %                     Launch = 0;
                %                 else
                tasks = [tasks; mouse_start(1:2), mouse_start(1:2)];
                new_task = 1;
                %                 end %Launch
                
            end
        end;
        ButtonDown = 0;                                     %Clear buttondown flag
    end %Mouse click up

    function Update_Vehicle_Status(V)
        % Currently works for ID 1 - 4 only!
        ID = V.ID;
        A_index = id2index(ID);
        Lat = V.lat;
        Lon = V.lon;
        Mode = V.custom_mode;
        %      Task_Lat = 'not transmitted';
        %      Task_Lon = 'not transmitted';
        Altitude = V.alt;
        Task_Brg = V.target_bearing;
        Task_Dist = V.target_distance;
        Voltage = V.voltage_battery/1000;
        if Voltage ~= 0
            A(A_index).voltage = (A(A_index).voltage*9+Voltage)/10;
        end %if Volts
        
        if A(A_index).voltage > Min_Volts
            volt_color = 'w';
        else
            volt_color = 'r';
        end %if low volts
        
        %      Nav_Bearing = V.nav_bearing; %I believe this is where it is trying to go
        
        
        Vehicle_ID_string = num2str(ID,' %u ');
        set(handles.display_Vehicle_ID(ID),'string',Vehicle_ID_string, ...
            'BackGroundcolor', colors(ID));
        
        if Mode ~= 0  %don't update if zero
            Mode_string = num2str(Mode,' %u ');
            set(handles.display_Mode(ID),'string',Mode_string);
        end %if
        
        if Lat ~= 0 %also don't update if zero
            Lat_Lon_string = num2str([Lat, Lon],' %u ');
            set(handles.display_Lat_Lon(ID),'string',Lat_Lon_string);
        end %if
        
        Voltage_string = num2str(A(A_index).voltage,' %f ');
        set(handles.display_Voltage(ID),'string',Voltage_string, ...
            'BackgroundColor', volt_color);
        if Altitude ~= 0
            Altitude_string = num2str(Altitude,' %u ');
            set(handles.display_Altitude(ID),'string',Altitude_string);
        end %if
        
        if Task_Dist ~= 0
            Task_Brg_Dist_string = num2str([Task_Brg, Task_Dist],' %u ');
            set(handles.display_Task_Brg_Dist(ID),'string',Task_Brg_Dist_string);
        end %if
        
    end %Update Vehicle Status


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Other Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function [dist1, dist2] = calculate_distance(vehicle_index, task_index)
        
        
        
        location = A(vehicle_index).location;
        heading = A(vehicle_index).heading;
        turn_radius = A(vehicle_index).turn_radius;
        point = tasks(task_index,:);
        vector = point(1:2) - location(1:2);
        bearing = 360/(2*pi())*atan2(vector(2),vector(1));
        angle_off = bearing - heading;
        angle_off = normalize(angle_off);
        %straight-line distance to arc exit point
        min_dist = abs(2*turn_radius*sind(angle_off));
        %arc distance is 2pir times twice angle off over
        %360.  Valid exactly for points on the circle,
        %angle from -180 to 180,over-estimates for points
        %far away.
        arc_dist = 4*pi()*turn_radius*abs(angle_off)/360  ;
        turn_weight = arc_dist - min_dist;
        dist1 = sqrt((location(1)-point(1))^2 + ...
            (location(2)-point(2))^2);
        if dist1 < min_dist*1.1
            turn_weight = 2*pi()*turn_radius;
        end
        dist1 = dist1 + turn_weight;
        %Check to see if point or line task
        if point(1:2) == point(3:4)
            %if point, weight second distance as infinite
            dist2 = inf;
        else
            %if line, add second distance and turn weight
            vector = point(3:4) - location(1:2);
            
            bearing = 360/(2*pi())*atan2(vector(2),vector(1));
            angle_off = bearing - heading;
            angle_off = normalize(angle_off);
            min_dist = abs(2*turn_radius*sind(angle_off));
            arc_dist = 4*pi()*turn_radius*abs(angle_off)/360  ;
            turn_weight = arc_dist - min_dist;
            dist2 = sqrt((location(1)-point(3))^2 + ...
                (location(2)-point(4))^2);
            if dist2 < min_dist*1.1
                turn_weight = 2*pi()*turn_radius;
            end
            dist2 = dist2 + turn_weight;
        end
        
        
    end


    function [swaths] = CutSwaths(rectangle, maxWidth)
        
        Width = rectangle(3);
        Height =rectangle(4);
        
        x1 = rectangle(1);
        x2 = x1 + Width;
        y1 = rectangle(2);
        y2 = y1 + Height;
        
        
        if Width > Height
            %shape = 'fat';
            n_cuts = ceil(Height/maxWidth);
            pathWidth = Height/n_cuts;
            for i = 1:n_cuts;
                swaths(i,:) = [x1 (y1+pathWidth/2+(i-1)*pathWidth) x2 (y1+pathWidth/2+(i-1)*pathWidth) ];
            end
            
        elseif Height > Width
            %shape = 'skinny';
            n_cuts = ceil(Width/maxWidth);
            pathWidth = Width/n_cuts;
            
            for i = 1:n_cuts;
                swaths(i,:) = [(x1+pathWidth/2+(i-1)*pathWidth) y2 (x1+pathWidth/2+(i-1)*pathWidth) y1 ];
            end
            
        else
            %shape = 'square';
            n_cuts = ceil(Height/maxWidth);
            pathWidth = Height/n_cuts;
            
            for i = 1:n_cuts;
                swaths(i,:) = [x1 (y1+pathWidth/2+(i-1)*pathWidth) x2 (y1+pathWidth/2+(i-1)*pathWidth) ];
            end
        end
    end



    function drawenvironment()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %drawenvironment function
        %
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cla(handles.balloon_axes)
        hold on
        line(World.BoundaryX,World.BoundaryY);
        
        hold on
        image([0 World.X], [World.Y 0],sat_image);
        
        %Draw vehicles
        for i = 1:size(A,2)
            plot3(handles.balloon_axes, A(i).location(1), A(i).location(2), World.Z/2, ...
                'o','markersize', 12, 'linewidth', 2, 'Color', colors(A(i).sysid));
            
            plot3(handles.balloon_axes, Home(A(i).sysid,1), Home(A(i).sysid,2), World.Z/2, ...
                'd','markersize', 8, 'linewidth', 1, 'Color', colors(A(i).sysid));
            
            if A(i).assigned
                if ~isempty(A(i).d_path) %plot calculated dubins path
                    line(A(i).d_path(:,1), A(i).d_path(:,2)); %Don't disable here, turn off where d_path calc'd
                    
                end
                
                % north line  TURNED OFF FOR NOW
                %             north_lat = 100 / 111111;
                %             north_lon = 0;
                %             north_delta_loc = ll2loc(left_point(1)+north_lat, left_point(2)+north_lon);
                %             north_loc = A(i).location + north_delta_loc;
                %             line([A(i).location(1) north_loc(1)], [A(i).location(2) north_loc(2)]);
                
                if ~isempty(A(i).nav_bearing) % draw line indicating nav direction
                    tgt_dist = A(i).target_distance;
                    bearing = A(i).nav_bearing;
                    %convert to lat/lon
                    nav_delta_lat = tgt_dist/111111 * cosd(bearing);
                    nav_delta_lon = tgt_dist/85200 * sind(bearing);
                    nav_delta_loc = ll2loc(nav_delta_lat+left_point(1), nav_delta_lon+left_point(2));
                    %add to left point, which is zero, to make distance on our map
                    nav_loc = A(i).location + nav_delta_loc;
                    
                    line([A(i).location(1) nav_loc(1)], [A(i).location(2) nav_loc(2)],'color','red');
                    
                end
                
                if ~isempty(A(i).target_bearing) % draw line indicating target direction
                    
                    tgt_dist = A(i).target_distance;
                    bearing = A(i).target_bearing;
                    %convert to lat/lon
                    tgt_delta_lat = tgt_dist/111111 * cosd(bearing);
                    tgt_delta_lon = tgt_dist/85200 * sind(bearing);
                    tgt_loc = ll2loc(tgt_delta_lat+left_point(1), tgt_delta_lon+left_point(2));
                    %             line([A(i).location(1) tgt_loc(1)], [A(i).location(2) tgt_loc(2)],'color','green');
                end
                
                if (A(i).task(1:2) == A(i).task(3:4))
                    plot3(handles.balloon_axes, A(i).task(1), A(i).task(2), World.Z/2, 'og');
                else
                    plot3(handles.balloon_axes, A(i).task(1), A(i).task(2), World.Z/2, 'og');
                    plot3(handles.balloon_axes, A(i).task(3), A(i).task(4), World.Z/2, 'og');
                    
                end
                
                if ~isempty(A(i).heading) % draw line indicating heading
                    tgt_dist = A(i).target_distance;
                    heading = A(i).heading;
                    %convert to lat/lon
                    hdg_delta_lat = tgt_dist/111111 * cosd(heading);
                    hdg_delta_lon = tgt_dist/85200 * sind(heading);
                    hdg_delta_loc = ll2loc(hdg_delta_lat+left_point(1), hdg_delta_lon+left_point(2));
                    %add to left point, which is zero, to make distance on our map
                    hdg_loc = A(i).location + hdg_delta_loc;
                    
                    line([A(i).location(1) hdg_loc(1)], [A(i).location(2) hdg_loc(2)],'color','black');
                    
                end
                
            end
        end
        if ~isempty(tasks)
            for i = 1:size(tasks,1)
                plot3(handles.balloon_axes, tasks(i,1), tasks(i,2), 12.5, 'xr');
                if tasks(i,1:2) == tasks(i,3:4)
                else
                    plot3(handles.balloon_axes, tasks(i,3), tasks(i,4), 12.5, 'xr');
                end
            end
        end
        drawnow
        %         heading = num2str(A(1).heading);
        %         set(handles.display_time_remaining, 'String', heading);
        
        %Draw obstacles
        if (obstacles)
            number_of_obstacles = size(obstacles,1);
            for i = 1:number_of_obstacles
                obstacle_edge = [obstacles(i,:)
                    obstacles(i,:)+[obstacle_sizes(i,1),0] %obstacle_sizes part of initial definitions, commented out
                    obstacles(i,:)+obstacle_sizes(i,:)
                    obstacles(i,:)+[0,obstacle_sizes(i,2)]
                    obstacles(i,:)];
                
                line(obstacle_edge(:,1),obstacle_edge(:,2),'LineWidth',2,'Color',[.8 .8 .8]);
                
            end
        else
            %number_of_obstacles = 0;
        end %if obstacles
        
        
    end %draw environment

    function [degrees] = normalize(degrees)
        %this function normalizes all angular degree measurements to -179 to
        %180
        if degrees <= -180
            degrees = degrees + 360;
        elseif degrees > 180
            degrees = degrees - 360;
        end
    end

    function [] = environment_generator()
        
        %Stolen from obstacle_generator code - currently hard-codes obstacle.
        %Should be expanded
        %obstacles are rectangles, defined by lower left corner and x,y size
        %obstacle location generated randomly, but limited to 1 unit or more from
        %edge of world.  Max obstacle size must be 2 or more smaller than world.
        
        %WORKING - not left justified.  Saves to folder MATLAB thinks its in, not
        %the one you think you are in.
        
        if (obstacles)
            number_of_obstacles = size(obstacles, 1);
        else number_of_obstacles = 0;
        end
        
        if number_of_obstacles > 1
            
            for i = 2:number_of_obstacles   %check for overlaps
                overlap_obstacle = 1;
                count = 0;
                while overlap_obstacle
                    count = count +1;
                    for j = 1:number_of_obstacles
                        if (i ~= j)
                            %check that this obstacles origin is not between another
                            %obstacles origin minus this ones size and the other
                            %obstacles origin plus its size.  Essentially expands the
                            %obstacle being checked against by the size of the current
                            %one.
                            inside(j) = obstacles(i,1) > obstacles(j,1)-obstacle_sizes(i,1)-1 && ...
                                obstacles(i,1) < obstacles(j,1)+obstacle_sizes(j,1)+1 &&...
                                obstacles(i,2) > obstacles(j,2)-obstacle_sizes(i,2)-1 && ...
                                obstacles(i,2) < obstacles(j,2)+obstacle_sizes(j,2)+1;
                        end
                    end
                    overlap_obstacle = sum(inside) > 0;
                    
                    if (overlap_obstacle)
                        obstacles(i,:) = random('unid',world_size-max_obstacle_size-1,[1,2]);
                        obstacle_sizes(i,:) = random('unid',max_obstacle_size-1,[1,2])+1;
                    end
                end
                
            end
        end
        
        
        
        filename = './test.environment';
        
        header_1 = '//Environment Model';
        header_2 = '//Outer Boundary x-y coordinates listed counterclockwise';
        
        %write first two lines.  No -append, so overwrites previous
        file_matrix = char(header_1, header_2);
        
        %build world boundary in CCW order
        outer_boundary = [0 0
            World.X 0
            World.X World.Y
            0 World.Y];
        for i = 1:size(outer_boundary,1)
            
            string =  sprintf(' %5.1f',outer_boundary(i,:));
            file_matrix = char(file_matrix, string);
        end
        
        %write world boundary, with -append so as not to overwrite headers
        %dlmwrite(filename, file_matrix,'-append', 'delimiter', '')
        
        %build obstacle header
        obstacle_header = '//Hole x-y coordinates listed clockwise' ;
        
        %write loop for each obstacle
        for i = 1:number_of_obstacles
            
            file_matrix = char(file_matrix, obstacle_header);
            vertices = [obstacles(i,:)
                obstacles(i,:)+[0,obstacle_sizes(i,2)]
                obstacles(i,:)+obstacle_sizes(i,:)
                obstacles(i,:)+[obstacle_sizes(i,1),0]];
            for j = 1:size(vertices,1)
                
                string =  sprintf('%5.1f',vertices(j,:));
                file_matrix = char(file_matrix, string);
            end
            %write obstacle headers and obstacle points, CW direction
        end
        dlmwrite(filename, file_matrix,'delimiter', '')
        
    end



    function [handles] = set_figure_properties(World, times)
        
        handles.Balloon_Figure = figure('position', [10 10 World.N World.M]);
        handles.balloon_axes = axes;
        
        %make sure figure is drawn before properties are set
        drawnow;
        
        set(handles.balloon_axes, 'Parent', handles.Balloon_Figure,...
            'units', 'pixels',...
            'position', [10 10 World.N-310 World.M-20],...
            'dataaspectratio', [1 1 1],...
            'xlimmode', 'manual',...
            'xlim', [-10,  World.X+10],...
            'ylimmode', 'manual',...
            'ylim', [-10,  World.Y+10]);
        
        
        
        %create text box ui control to display mouse position
        
        %Set props of figure and define mouse motion callback function
        set(   handles.Balloon_Figure, ...
            'color', [0 0 0],...
            'menubar', 'none',...
            'toolbar', 'none',...
            'name', 'Graphics Output Wndow',...
            'numbertitle', 'off', ...
            'pointer', 'crosshair', ...
            'WindowButtonDown', {@Balloon_Figure_ButtonDownFcn},...
            'WindowButtonUp', {@Balloon_Figure_ButtonUpFcn},...
            'WindowButtonMotionFcn', {@Balloon_Figure_MotionFcn}, ...
            'DeleteFcn', {@Balloon_Figure_Delete_Function});
        
        %Build editable text windows
        handles.edit_new_point = uicontrol(handles.Balloon_Figure, ...
            'Style', 'edit', ...
            'string', 'Enter a point',...
            'position', [World.N-250 World.M-275 100 20]);
        
        handles.label_new_point =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-250 World.M-250 100 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Enter a new point', ...
            'FontSize', 8);
        
        
        %         handles.display_time_remaining =  uicontrol(handles.Balloon_Figure, ...
        %             'Style', 'text', ...
        %             'Units', 'Pixels', ...
        %             'Position', [World.N-250 World.M-400 100 20], ...
        %             'String','', ...
        %             'FontSize', 8);
        
        %         handles.label_time_remaining =  uicontrol(handles.Balloon_Figure, ...
        %             'Style', 'text', ...
        %             'Units', 'Pixels', ...
        %             'Position', [World.N-250 World.M-375 100 20], ...
        %             'BackgroundColor', [0 0 0], ...
        %             'ForegroundColor', 'w', ...
        %             'String','Time Remaining', ...
        %             'FontSize', 8);
        
        handles.display_lat_lon =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-275 World.M-500 150 20], ...
            'String','', ...
            'FontSize', 8);
        
        handles.label_lat_lon =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-250 World.M-475 100 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','lat lon', ...
            'FontSize', 8);
        handles.display_location =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-275 World.M-550 150 20], ...
            'String','', ...
            'FontSize', 8);
        
        handles.label_location =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-250 World.M-525 100 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Location', ...
            'FontSize', 8);
        
        
        
        % Build Vehicle Status Displays
        %One label, 4 vehicles (or do stack of four?) Why am I doing this
        %by hand?!
        kerning = 10;
        Vehicle_ID_N = 1000; %First column
        ID_W = 60;
        Mode_W = 60;
        LL_W = 150;
        Voltage_W = 60;
        Altitude_W = 60;
        Task_Hdg_W = 100;
        Mode_N = Vehicle_ID_N - ID_W - kerning;
        LL_N = Mode_N - Mode_W - kerning;
        Voltage_N = LL_N - LL_W - kerning;
        Altitude_N = Voltage_N - Voltage_W - kerning;
        Task_Hdg_N = Altitude_N - Altitude_W - kerning;
        
        Status_Label_M = 675;
        n_rows = 4;
        row_height = 25;
        row(1) = Status_Label_M + row_height;
        row(2) = row(1) + row_height;
        row(3) = row(2) + row_height;
        row(4) = row(3) + row_height;
        
        
        
        %I had 4 rows, dropped while debugging.  Should convert to
        %columns,i
        handles.label_Vehicle_ID =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-Vehicle_ID_N World.M-Status_Label_M ID_W 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Vehicle ID', ...
            'FontSize', 8);
        for l = 1:n_rows
            handles.display_Vehicle_ID(l) =  uicontrol(handles.Balloon_Figure, ...
                'Style', 'text', ...
                'Units', 'Pixels', ...
                'Position', [World.N-Vehicle_ID_N World.M-row(l) ID_W 20], ...
                'String','', ...
                'FontSize', 8);
        end %for
        
        
        handles.label_Mode =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-Mode_N World.M-Status_Label_M Mode_W 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Mode', ...
            'FontSize', 8);
        for l = 1:n_rows
            handles.display_Mode(l) =  uicontrol(handles.Balloon_Figure, ...
                'Style', 'text', ...
                'Units', 'Pixels', ...
                'Position', [World.N-Mode_N World.M-row(l) Mode_W 20], ...
                'String','', ...
                'FontSize', 8);
        end %for
        
        
        handles.label_Lat_Lon =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-LL_N World.M-Status_Label_M LL_W 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Lat Lon', ...
            'FontSize', 8);
        for l = 1:n_rows
            handles.display_Lat_Lon(l) =  uicontrol(handles.Balloon_Figure, ...
                'Style', 'text', ...
                'Units', 'Pixels', ...
                'Position', [World.N-LL_N World.M-row(l) LL_W 20], ...
                'String','', ...
                'FontSize', 8);
        end %for rows
        
        
        handles.label_Voltage =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-Voltage_N World.M-Status_Label_M Voltage_W 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Voltage', ...
            'FontSize', 8);
        for l = 1:n_rows
            handles.display_Voltage(l) =  uicontrol(handles.Balloon_Figure, ...
                'Style', 'text', ...
                'Units', 'Pixels', ...
                'Position', [World.N-Voltage_N World.M-row(l) Voltage_W 20], ...
                'String','unavailable', ...
                'FontSize', 8);
        end % for rows
        
        
        handles.label_Altitude =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-Altitude_N World.M-Status_Label_M Altitude_W 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Altitude', ...
            'FontSize', 8);
        for l = 1:n_rows
            handles.display_Altitude(l) =  uicontrol(handles.Balloon_Figure, ...
                'Style', 'text', ...
                'Units', 'Pixels', ...
                'Position', [World.N-Altitude_N World.M-row(l) Altitude_W 20], ...
                'String','', ...
                'FontSize', 8);
        end %for rows
        
        
        handles.label_Task_Brg_Dist =  uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-Task_Hdg_N World.M-Status_Label_M Task_Hdg_W 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','Task brg/dist', ...
            'FontSize', 8);
        for l = 1:n_rows
            handles.display_Task_Brg_Dist(l) =  uicontrol(handles.Balloon_Figure, ...
                'Style', 'text', ...
                'Units', 'Pixels', ...
                'Position', [World.N-Task_Hdg_N World.M-row(l) Task_Hdg_W 20], ...
                'String','', ...
                'FontSize', 8);
        end %for rows
        
        
        % Build activate/deactive radiobuttons
        
        Act_Btn_W = 20;
        Act_Btn_H = 20;
        Act_Kern = 25;
        %         Act_Row = 25;
        Act_N = Task_Hdg_N -Task_Hdg_W - Act_Kern;
        %         Act_M = 600;
        
        %         Act_label_M = Act_M;
        %         Act_row(1) = Act_label_M + Act_Row;
        %         Act_row(2) = Act_row(1) + Act_Row;
        %         Act_row(3) = Act_row(2) + Act_Row;
        %         Act_row(4) = Act_row(3) + Act_Row;
        
        Act_column_1 = Act_N;
        Act_column_2 = Act_column_1-Act_Kern;
        Act_column_3 = Act_column_2-Act_Kern;
        
        
        
        
        %build label for buttons so buttons can be unmarked
        handles.label_activate_buttons = uicontrol(handles.Balloon_Figure, ...
            'Style', 'text', ...
            'Units', 'Pixels', ...
            'Position', [World.N-Act_column_1 World.M-Status_Label_M 95 20], ...
            'BackgroundColor', [0 0 0], ...
            'ForegroundColor', 'w', ...
            'String','ON   OFF', ...
            'FontSize', 8);
        for l = 1:4
            q_string = num2str(l);
            handles.label_activate_row(l) = uicontrol(handles.Balloon_Figure, ...
                'Style', 'text', ...
                'Units', 'Pixels', ...
                'Position', [World.N-Act_column_1 World.M-row(l) 20 20], ...
                'BackgroundColor', [0 0 0], ...
                'ForegroundColor', 'w', ...
                'String',q_string, ...
                'FontSize', 8);
            %
            %         handles.label_activate_row_2 = uicontrol(handles.Balloon_Figure, ...
            %                                         'Style', 'text', ...
            %                                         'Units', 'Pixels', ...
            %                                         'Position', [World.N-Act_column_1 World.M-Act_row_2 20 20], ...
            %                                         'BackgroundColor', [0 0 0], ...
            %                                         'ForegroundColor', 'w', ...
            %                                         'String','2', ...
            %                                         'FontSize', 8);
            %
            %         handles.label_activate_row_3 = uicontrol(handles.Balloon_Figure, ...
            %                                         'Style', 'text', ...
            %                                         'Units', 'Pixels', ...
            %                                         'Position', [World.N-Act_column_1 World.M-Act_row_3 20 20], ...
            %                                         'BackgroundColor', [0 0 0], ...
            %                                         'ForegroundColor', 'w', ...
            %                                         'String','3', ...
            %                                         'FontSize', 8);
            %
            %         handles.label_activate_row_4 = uicontrol(handles.Balloon_Figure, ...
            %                                         'Style', 'text', ...
            %                                         'Units', 'Pixels', ...
            %                                         'Position', [World.N-Act_column_1 World.M-Act_row_4 20 20], ...
            %                                         'BackgroundColor', [0 0 0], ...
            %                                         'ForegroundColor', 'w', ...
            %                                         'String','4', ...
            %                                         'FontSize', 8);
            
            handles.activate(l) = uicontrol(handles.Balloon_Figure, ...
                'Style', 'radiobutton', ...
                'Callback', @activate_callback, ...
                'Units', 'Pixels', ...
                'Position', [World.N - Act_column_2, World.M - row(l), Act_Btn_W, Act_Btn_H], ...
                'String', '', ...
                'Value', 0, ...
                'callback', {@activate_callback});
            
            handles.deactivate(l) = uicontrol(handles.Balloon_Figure, ...
                'Style', 'radiobutton', ...
                'Callback', @deactivate_callback, ...
                'Units', 'Pixels', ...
                'Position', [World.N - Act_column_3, World.M - row(l), Act_Btn_W, Act_Btn_H], ...
                'String', '', ...
                'Value', 1, ...
                'callback', {@deactivate_callback});
            
        end %for
        %
        % set(handles.activate(:), 'callback', {@activate_callback});
        %
        % set(handles.deactivate(:), 'callback', {@deactivate_callback});
        
        %Activate/deactivate controls whether the GUI will plan to use the
        %particular vehicle and, more importantly, whether it will continue to send
        %Guided command messages.  This is important because a Guided message
        %over-rides the manual/auto input from the RC controller.  The vehicle MUST
        %be deactivated before attempting to take manual control of the aircraft
        
        %Currently requires sysids match with index, ie, only 4 spaces built, sysids
        %must be 1 to 4
        
        function activate_callback(ThisButton, ~)
            I_exist = 0;
            my_index = [];
            switch ThisButton
                case handles.activate(1)
                    q = 1;
                case handles.activate(2)
                    q = 2;
                case handles.activate(3)
                    q = 3;
                case handles.activate(4)
                    q = 4;
            end
            
            for p = 1:size(A,2)     %check if this sysid exists
                if ~(isempty(A(p).sysid)) && A(p).sysid == q
                    I_exist = 1;
                    my_index = p;
                end
            end
            
            if I_exist %aircraft exists?
                % VEHICLES ACTIVATE!!!1!
                % Set buttons
                set(handles.deactivate(q), 'Value', 0);
                set(handles.activate(q), 'Value', 1);
                % set activate flag
                A(my_index).active = 1;
                
            else
                %Stay dormant
                set(handles.deactivate(q), 'Value', 1);
                set(handles.activate(q), 'Value', 0);
            end
        end
        
        
        function deactivate_callback(ThisButton, ~)
            I_exist = 0;
            my_index = [];
            switch ThisButton
                case handles.deactivate(1)
                    q = 1;
                case handles.deactivate(2)
                    q = 2;
                case handles.deactivate(3)
                    q = 3;
                case handles.deactivate(4)
                    q = 4;
            end
            for p = 1:size(A,2)     %check if this sysid exists
                if ~(isempty(A(p).sysid)) && A(p).sysid == q
                    I_exist = 1;
                    my_index = p;
                end
            end
            if I_exist %aircraft exists?
                % You are dead to me
                % Set buttons
                set(handles.deactivate(q), 'Value', 1);
                set(handles.activate(q), 'Value', 0);
                % set activate flag
                A(my_index).active = 0;
                Go_Home(my_index);  %Send inactive aircraft home - moves to known place and separate altitude
                
            else
                %Stay dormant
                set(handles.deactivate(q), 'Value', 1);
                set(handles.activate(q), 'Value', 0);
            end
        end
        
        
        
        
        %Build Pushbuttons
        handles.pushbutton_reset_tasks = uicontrol(handles.Balloon_Figure, ...
            'Style', 'togglebutton', ...
            'string', 'Reset Tasks',...
            'Min',0,'Max',1,'Value',1,...
            'position', [World.N-250 World.M-225 150 25]);
        %         handles.pushbutton_Launch_New_Vehicle = uicontrol(handles.Balloon_Figure, ...
        %             'Style', 'pushbutton', ...
        %             'string', 'Launch',...
        %             'position', [World.N-250 World.M-325 50 25]);
        
        
        %%%%%%%%%%%%%%%
        %set callbacks%
        %%%%%%%%%%%%%%%
        set(handles.edit_new_point, 'callback', {@Edit_new_point_Callback});
        %         set(handles.pushbutton_Launch_New_Vehicle, 'callback', {@pushbutton_Launch_New_Vehicle_callback});
        set(handles.pushbutton_reset_tasks, 'callback', {@pushbutton_reset_tasks_callback});
        
        
        
        % Build Timer
        handles.Loop_Timer = timer('TimerFcn',@Simulation_Callback, ...
            'Period', times.deltat, ...
            'ExecutionMode', 'fixedRate');
    end %figure properties



end %Primary program

