function [structure] = total_struct_comp_dz_neg(yourpath)
K = 1;
plots = true;

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
    
    if plots == 1
        
        
EDGES = [-11.25:2.5:11.25];

 %EDGES = [3*-4.375:1.25:3*6.875];
  %EDGES = [-6.25:2.5:6.25];
  %EDGES = [-5.625:1.25:5.625];
  figure(1)
load([yourpath, '/', 'data_total_dz_poz.mat'])
histogram(cell2mat({dz_poz(1:end).EPIvsTIRF_s}), EDGES)
title('Histogram of dz(+) puncta')
figure(2)
load([yourpath, '/', 'data_total_dz_neg.mat'])
histogram(cell2mat({dz_neg(1:end).EPIvsTIRF_s}), EDGES)
title('Histogram of dz(-) puncta')

 
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
