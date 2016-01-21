function [C_T_TEP,C_Q_TEP] = TEP_pred(a,c_d_0,Prop_props,lambda)

% TEP
for i=1:size(lambda,1)
    for j=1:size(lambda,2) 
        C_T_TEP(i,j) = Prop_props.sigma*a/4*( Prop_props.theta_0*2/3+Prop_props.theta_1/2  -  lambda(i,j) );
        C_Q_TEP(i,j) = Prop_props.sigma*a/4*( Prop_props.theta_0*2/3+Prop_props.theta_1/2  -  lambda(i,j) )*lambda(i,j) + Prop_props.sigma*c_d_0/8;
    end
end



end