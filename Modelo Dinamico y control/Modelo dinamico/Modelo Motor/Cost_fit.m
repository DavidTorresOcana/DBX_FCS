function Cost = Cost_fit(throtle,Mom,Omega,a,b,c) % Throle less than 16 (Saturation)

m = size(Omega,1);
Cost=0;

for i=1:m
    Cost = Cost + ( Omega(i) - FF(throtle(i),Mom(i),a,b,c) )^2;
end




end