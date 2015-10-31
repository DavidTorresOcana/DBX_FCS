function Simulation_3_copter(block)
% Level-2 MATLAB file S-Function for displaying Skeleton joints for Simulink NID Skeleton data.
%
% Copyright 2011 The MathWorks, Inc.
%

% Register number of input and output ports
block.NumInputPorts   = 8;
block.NumOutputPorts  = 0;
% Setup functional port properties to dynamically inherited.
block.AllowSignalsWithMoreThan2D = 1;
block.SetPreCompInpPortInfoToDynamic;
% Set block sample time to inherited
block.SampleTimes = [-1 0];
% Register methods
block.RegBlockMethod('SetInputPortDimensions', @SetInputPortDims);
block.RegBlockMethod('Start',   @Start);
block.RegBlockMethod('Outputs', @Output);  
%endfunction

% -----------------------------------------------------------------
% Callback functions
% -----------------------------------------------------------------

function SetInputPortDims(block, idx, di)
block.InputPort(idx).Dimensions = di; % Set compiled dimensions
%endfunction

function Start(block)
set(gcf, 'Name', '3-Copter Viewer', 'NumberTitle', 'off');

%endfunction

function Output(block)

    
    
    Plot_3_copter(block.InputPort(1).Data,block.InputPort(2).Data,block.InputPort(3).Data,block.InputPort(4).Data,block.InputPort(5).Data,...
        block.InputPort(6).Data(1),block.InputPort(6).Data(2),block.InputPort(7).Data(1),block.InputPort(7).Data(2),...
        block.InputPort(8).Data(1),block.InputPort(8).Data(2) )

    
    
% set(gca, 'XGrid', 'on', 'YGrid', 'on'); % Draw X/Y grid
%
