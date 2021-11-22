%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b / to merge all detected track from all cells form
%%% one experiment

function [structure] = struct_comp(yourpath, name, path2save)
K = 1;
plots = true;

ContentInFold = dir(yourpath);
    for i = 3:length(ContentInFold)
        if strfind(ContentInFold(i).name, 'dzvsCLC.mat') >= 1
            path = [ContentInFold(i).folder, '/', ContentInFold(i).name];

            if K == 1
                load(path)
                K = 2;
            elseif K == 2
                a = load(path);
                data = [data, a.data];
            end
        end
    end
    
    data_total = data;
    save([path2save, '/', 'data_', name, '.mat'], 'data_total')
    
    if plots == 1

    EDGES = [-5.5:1:round(max([data.dz_s])+3)];
     %histogram generation
    figure(1) 
        histogram(cell2mat({data(1:end).dzvsCLC_s}), EDGES)
        xlabel('dz begining time vs clc signal');
        ylabel('Frequency');
     
    [~,name,~] = fileparts(yourpath);  
    %evnets clasificaiton
    my_CME_classifier(data_total, name);
 
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    savefig(FigList, [yourpath, '/', 'data_total_fig.fig'])
    close all
    end
end
