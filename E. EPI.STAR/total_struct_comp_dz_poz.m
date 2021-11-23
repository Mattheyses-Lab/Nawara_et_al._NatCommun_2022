%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function [structure] = total_struct_comp_dz_poz(yourpath)
K = 1;
plots = false;

ContentInFold = dir(yourpath);
    for i = 3:length(ContentInFold)
        if strfind(ContentInFold(i).name, 'poz') >= 1
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
    
    save([yourpath, '/', 'data_total_dz_poz.mat'], 'dz_poz')
    
    if plots == 1
        data_total = EAP_POZ;

    EDGES = [-7.5:3:round(max([data_total.dz_s])+3)];
    
    figure(1) 
        histogram(cell2mat({data_total(1:end).dzvsCLC_s}), EDGES)
        xlabel('dz begining time vs clc signal');
        ylabel('Frequency');
     
    [~,name,~] = fileparts(yourpath);  
    my_CME_calsifier_plus(data_total, name);
 
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    savefig(FigList, [yourpath, '/', 'data_total_fig_EAP_POZ.fig'])
    close all
    end
    
%     edges = [10,20,40,60,80,100];
%     histogram(cell2mat({data_total(1:end).lifetime_s}), edges)
%     xlabel('Lifetime Cohort')
%     ylabel('# of puncta')
%     title('Histogram of dz(+) puncta')
    
end
