function f=FF(x,y,a,b,c)


f=max(0, min((a*log((x)*atan2(x,y))+b)/(y+c),(a*log((x)*atan2(x,y))+b)/(y+c)   ) );
end