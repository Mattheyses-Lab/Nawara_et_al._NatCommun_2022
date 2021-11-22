%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b / to merge all detected track from all experimetns

function [structure] = total_struct_comp(yourpath)
K = 1;
plots = true;

ContentInFold = dir(yourpath);
    for i = 3:length(ContentInFold)
        if strfind(ContentInFold(i).name, 'data') >= 1
            path = [ContentInFold(i).folder, '/', ContentInFold(i).name];

            if K == 1
                load(path)
                K = 2;
            elseif K == 2
                a = load(path);
                data_total = [data_total, a.data_total];
            end
        end
    end
    
    %save([yourpath, '/', 'data_total.mat'], 'data_total')
    
    if plots == 1

    EDGES = [-5.5:1:round(max([data_total.dz_s])+3)];
    
    %histogram generation
    figure(1) 
        histogram(cell2mat({data_total(1:end).dzvsCLC_s}), EDGES)
        xlabel('dz begining time vs clc signal');
        ylabel('Frequency');
     
    [~,name,~] = fileparts(yourpath);
    %evnets clasificaiton
    [data_total] = my_CME_classifier(data_total, name);
    
    save([yourpath, '/', 'data_total.mat'], 'data_total')
 
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    savefig(FigList, [yourpath, '/', 'data_total_fig.fig'])
    close all
    end
    
%     edges = [10,20,40,60,80,100];
%     histogram(cell2mat({data_total(1:end).lifetime_s}), edges)
%     xlabel('Lifetime Cohort')
%     ylabel('# of puncta')
%     title('Histogram of dz(+) puncta')
    
end
