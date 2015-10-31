function Plot_3_copter(pos,DCM,r_p_1,r_p_2,r_p_3,eta_1,gamma_1,eta_2,gamma_2,eta_3,gamma_3)
persistent h_plot1 h_plot2

r_p_1=DCM*r_p_1+pos;
r_p_2=DCM*r_p_2+pos;
r_p_3=DCM*r_p_3+pos;


l_sim=0.345;
h_sim=0.08;

r1=DCM*[l_sim,0,0]'+pos;
r2 = DCM*[-l_sim*cosd(60),l_sim*sind(60),0]'+pos;
r3 = DCM*[-l_sim*cosd(60),-l_sim*sind(60),0]'+pos;
rr=DCM*[-l_sim*cosd(60),0,0]'+pos;



% Body

if isempty(ishandle(h_plot1))==1 || ishandle(h_plot1)==0 
    h_plot1=plot3([rr(1),r1(1)],-[rr(2),r1(2)],-[rr(3),r1(3)],'b','Linewidth',5);
    hold on

else
    set(h_plot1,'XData',[rr(1),r1(1)],'YData',-[rr(2),r1(2)],'ZData',-[rr(3),r1(3)] );
end


% Disc 1
plot_disc1(DCM,r_p_1,eta_1,gamma_1)
% Disc 2
plot_disc2(DCM,r_p_2,-eta_2,-gamma_2)
% Disc 3
plot_disc3(DCM,r_p_3,-eta_3,-gamma_3)


% Body

if isempty(ishandle(h_plot2))==1 || ishandle(h_plot2)==0 
    h_plot2=plot3([r2(1),r3(1)],-[r2(2),r3(2)],-[r2(3),r3(3)],'Linewidth',5);
    grid
    axis equal
else
    set(h_plot2,'XData',[r2(1),r3(1)],'YData',-[r2(2),r3(2)],'ZData',-[r2(3),r3(3)] );
end




% Ground
% x=[pos(1)-1:1:pos(1)+1];
% y=[pos(2)-1:1:pos(2)+1];
% [x,y] = meshgrid(x,y); 
% C(:,:,1)=0.543*ones(size(x));% 139/256-69/256-19/256
% C(:,:,2)=0.2695*ones(size(x));
% C(:,:,3)=0.0742*ones(size(x));

% surf(x,y,zeros(size(x)),C);

% How to view
axis([pos(1)-0.5,pos(1)+0.5,-pos(2)-0.5,-pos(2)+0.5,-pos(3)-0.5,-pos(3)+0.5] )

% campos([pos(1)-0.5,pos(2)-0.5,pos(3)+0.2])
camtarget([pos(1),-pos(2),-pos(3)])


end