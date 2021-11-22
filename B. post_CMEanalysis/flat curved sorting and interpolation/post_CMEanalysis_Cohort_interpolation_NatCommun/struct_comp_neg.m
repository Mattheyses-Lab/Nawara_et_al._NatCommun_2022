function [a] = struct_comp_neg(yourpath, name, path2save)
K = 1;
plots = false;

ContentInFold = dir(yourpath);
    for i = 3:length(ContentInFold)
        if strfind(ContentInFold(i).name, 'dz_neg.mat') >= 1
            path = [ContentInFold(i).folder, '/', ContentInFold(i).name];

            if K == 1
                load(path)
                K = 2;
            elseif K == 2
                a = load(path);
                dz_neg = [dz_neg, a.dz_neg];
            end
        end
    end   
    save([path2save, '/', 'data_', name, 'dz_neg.mat'], 'dz_neg')
end
