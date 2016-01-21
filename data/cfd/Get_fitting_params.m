function Struct_out = Get_fitting_params(fitresult,Struct)


Struct_out = Struct; 

match_idx = strfind(Struct.Expre_regu,'a_');
for i = 1:length(match_idx)
    name_a = Struct.Expre_regu(match_idx(i):match_idx(i)+2);
    
    eval(['Struct_out.a(',num2str(i),') = fitresult.',name_a,';']);
end


end