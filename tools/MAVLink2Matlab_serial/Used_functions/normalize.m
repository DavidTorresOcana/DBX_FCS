function [degrees] = normalize(degrees)
%this function normalizes all angular degree measurements to -179 to
%180
if degrees <= -180
    degrees = degrees + 360;
elseif degrees > 180
    degrees = degrees - 360;
end
end