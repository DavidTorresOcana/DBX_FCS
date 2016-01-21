% Obtención de ficheros de datos Xflow en carpeta /data
function file_list_struct = get_xflow_files()

% cd (dir_name)
file_list_struct = dir('*.txt');
% cd ..
end