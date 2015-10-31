%%
% clear all
close all
clc
global h_surf h_quiver

l_sim=0.345;
h_sim=0.08;

r1=[l_sim,0,-h_sim]';
r2 = [-l_sim*cosd(60),l_sim*sind(60),-h_sim]';
r3 = [-l_sim*cosd(60),-l_sim*sind(60),-h_sim]';

DCM=[cosd(30),0,sind(30);
    0,1,0;
    -sind(30),0,cosd(30)];

Plot_3_copter([10,10,-10]',DCM,r1,r2,r3,0,0,0,0,0,0 )