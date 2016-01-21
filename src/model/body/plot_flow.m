

size_struct =(size(xflow_data,2));


X = zeros(size_struct,1);
Y = zeros(size_struct,1);

for i = 1:size_struct
   hold on
   X(i,1) = xflow_data(i).alfa;
   Y(i,1) = xflow_data(i).Fz;
   plot(X,Y,'o')
    
    
end

grid minor