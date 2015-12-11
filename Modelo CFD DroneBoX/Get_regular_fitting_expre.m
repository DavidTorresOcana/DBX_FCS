function Expre_regu = Get_regular_fitting_expre(Struct)


Struct_out = Struct; 

% Substitute x
split_expre = strsplit(Struct.Expre,Struct.x_name);
Expre_regu = split_expre{1};

for i = 1:length(split_expre)-1
    Expre_regu = [Expre_regu, 'x',split_expre{i+1}];
end

% Substitute y
split_expre = strsplit(Expre_regu,Struct.y_name);
Expre_regu = split_expre{1};

for i = 1:length(split_expre)-1
    Expre_regu = [Expre_regu, 'y',split_expre{i+1}];
end

end