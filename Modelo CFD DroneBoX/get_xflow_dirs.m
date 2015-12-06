% Este script accede a la carpeta data para listar las diferentes carpetas

function dir_list = get_xflow_dirs()

    cd data

    temp = dir;
    size_temp = size(temp,1);
    counter = 1;

    for i = 3:size_temp
        if double(temp(i).isdir)>0;
        dir_list{counter} = temp(i).name; 
        counter = counter + 1;
        else
            break
        end
    end

    cd ..


end