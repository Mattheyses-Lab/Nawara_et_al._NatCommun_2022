function [a] = struct_comp_poz(yourpath, name, path2save)
K = 1;

ContentInFold = dir(yourpath);
    for i = 3:length(ContentInFold)
        if strfind(ContentInFold(i).name, 'dz_poz.mat') >= 1
            path = [ContentInFold(i).folder, '/', ContentInFold(i).name];

            if K == 1
                load(path)
                K = 2;
            elseif K == 2
                a = load(path);
                dz_poz = [dz_poz, a.dz_poz];
            end
        end
    end
    
    save([path2save, '/', 'data_', name, 'dz_poz.mat'], 'dz_poz')
end