classdef MAVLink_vehicle_CLASS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Moving vehicle.  Used with OOP_Flying_GUI.  Moves incrementally,
    %turns, and homes toward a point
    %
    %Version 1.0
    %
    %
    %Coded by Chad Bieber
    %   Nov 2012
    %
    %
    %  No longer broken - commented part trying to turn to pose
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Dependent)
        %Dependent properties are calculated on-demand
    end
    properties
        %Specify properties
        %State information from vehicle
        sysid = [];             % System ID of vehicle
        location = [1 1];       %x,y position of vehicle
        latlon = []
        heading = 0;            % current direction of travel -179 to +180
                                % 0 is positive x axis, 180 is negative x
                                % axis, positive angles ccw, negative cw
        speed = [];              % speed vehicle is moving
        alt = [];
        roll = [];      % Actual attitude
        pitch = [];
        yaw = [];
        throttle = [];
        nav_roll = [];  % nav_ is what ardupilot is commanding
        nav_pitch = [];
        nav_yaw = [];
        nav_throttle = [];
        slider_roll = [];   %Slider is commanded by GUI
        slider_pitch = [];
        slider_yaw = [];
        slider_throttle = [];
        
        turn_radius = 5;    % This is to make Dubins path work.  
                            % Should find a way of calculating
        
        target = [];
        nav_bearing = [];
        target_bearing = [];
        target_distance = [];
        d_path = [];            %dubin's path - separate from path around obstacles for now

        voltage = 12;           %Holds averaged voltage, initialized to 12 
        nav_state = [];
        task = [];              % Current task vehicle is assigned
                                % [x y x y] - second pair indicate end of
                                % line if line task.  For point task, both
                                % points the same.
                                
        active = 0;             % flag indicating vehicle has been activated
        assigned = 0;           % flag indicating vehicle has been assigned a task
        executing = 0;          % flag indicates vehicle is executing a 
                                % task and cannot be reassigned
        arrived = 0;            %flag indicating arrival at task
        
        path = [];              %obstacle path - this is actually used for nav
        current_path = [];      %this is point on path currently headed for
        path_history = [];      %this records where vehicle has flown
        
        
    end
    
    methods
        % methods, including constructor defined here
        
        function obj = vehicle_CLASS(location)
            %class constructor, builds the objects of this class
            if (nargin>0)
                obj.location = location;
            end
            
        end %vehicle class constructor
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Dependent Variable Functions%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
        %Previous class had turn radius and some other things calculated on
        %the fly here
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Other Functions                          %
        %Primarily motion/flight functions, so far%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        %previous class had move, turn, other functions here.  What is
        %needed?
        
        
    end %methods
end %classdef
