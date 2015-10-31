%% 
clear all 
clc
close all

load('TO_curve_raw.mat')

plot(throtle,Omega,'*')

Throtle_TO=(0:0.2:36)';


TO_fit = TO_curve_fit(throtle, Omega);

Omega_TO= TO_fit(Throtle_TO);


figure
plot(Throtle_TO,Omega_TO)