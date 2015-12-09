%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: C:\Users\David\Documents\Estudios y formación academica\Proyectos\xxcopter\trunk\Modelling and Control\xflow\Datos Aero DBX v2.xlsx
%    Worksheet: Estimaciones teóricas
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2015/12/06 18:11:09

%% Import the data
[~, ~, raw0_0] = xlsread('.\Datos Aero DBX v2.xlsx','Estimaciones teóricas','A5:A13');
[~, ~, raw0_1] = xlsread('.\Datos Aero DBX v2.xlsx','Estimaciones teóricas','C5:C13');
raw = [raw0_0,raw0_1];
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1);
raw = raw(:,2);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Create table
DatosAeroDBXv2S2 = table;

%% Allocate imported array to column variable names
DatosAeroDBXv2S2.Coefficients_damping = cellVectors(:,1);
DatosAeroDBXv2S2.value = data(:,1);

%% Clear temporary variables
clearvars data raw raw0_0 raw0_1 cellVectors;