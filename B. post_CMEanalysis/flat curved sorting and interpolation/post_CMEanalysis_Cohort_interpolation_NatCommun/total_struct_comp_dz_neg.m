function [structure] = total_struct_comp_dz_neg(yourpath)
K = 1;

ContentInFold = dir(yourpath);
    for i = 3:length(ContentInFold)
        if strfind(ContentInFold(i).name, 'neg') >= 1
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
    
    save([yourpath, '/', 'data_total_dz_neg.mat'], 'dz_neg')
end