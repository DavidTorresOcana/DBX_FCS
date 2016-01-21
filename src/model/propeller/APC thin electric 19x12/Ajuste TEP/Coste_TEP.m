function Cost = Coste_TEP(a,c_d_0,Prop_props,PropTEP)

[C_T_TEP,C_Q_TEP] = TEP_pred(a,c_d_0,Prop_props,PropTEP.lambda);


Dif_1 = PropTEP.C_T_test-C_T_TEP;
Dif_1( isnan(PropTEP.C_T_test) ) =0;

Dif_2 = PropTEP.C_Q_test-C_Q_TEP;
Dif_2( isnan(PropTEP.C_Q_test) ) =0;

Cost = sum(sum( (Dif_1).^2)  ) + 1*sum(sum( (Dif_2).^2)  );

end
