function [C_T_TEP,C_Q_TEP] = TEP_mod_pred(a,c_d_0,lambda_0_T,kappa_T,lambda_0_Q,kappa_Q,Prop_props,lambda)

% TEP modificada para grandes J
for i=1:size(lambda,1)
    for j=1:size(lambda,2) 
        C_T_TEP(i,j) = Prop_props.sigma*a/4*( Prop_props.theta_0*2/3+Prop_props.theta_1/2  -  kappa_T*(lambda(i,j)-lambda_0_T)^2 );
        C_Q_TEP(i,j) = Prop_props.sigma*a/4*( Prop_props.theta_0*2/3+Prop_props.theta_1/2  -  kappa_Q*(lambda(i,j)-lambda_0_Q)^2 )*kappa_Q*(lambda(i,j)-lambda_0_Q)^2+ Prop_props.sigma*c_d_0/8;
    end
end



end