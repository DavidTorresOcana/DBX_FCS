% % options=optimset('Display','iter','LargeScale','off','TolFun',10e-9,'TolX',10e-11,'MaxFunEvals',6000,'MaxIter',6000);
% % 
% % [X,fval]= fminunc( @(X) TrimCostFunction(X), 100*[throtle_1,throtle_23,eta_23] )
% % 
% % throtle_1=X(1)/100;
% % throtle_23=X(2)/100;
% % eta_23=X(3)/100;
% % 
% % Cost = TrimCostFunction(100*[throtle_1,throtle_23,eta_23])