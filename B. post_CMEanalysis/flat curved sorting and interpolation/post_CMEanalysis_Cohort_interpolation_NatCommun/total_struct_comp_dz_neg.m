%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


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