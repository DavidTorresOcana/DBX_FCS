function Cost=TrimCostFunction(X)
global throtle_1 throtle_23 eta_23
throtle_1=X(1)/100;
throtle_23=X(2)/100;
eta_23=X(3)/100;

% pause
[~,~,y] = sim('Trim_Model',[0,0.1],[],'[throtle_1,throtle_23,eta_23]');

Cost=y(end);
end
