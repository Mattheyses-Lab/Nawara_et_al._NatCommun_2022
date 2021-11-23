%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function [a] = struct_comp_poz(yourpath, name, path2save)
K = 1;
%plots = true;

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

% if plots == 1
% data = dz_poz;
% 
% ww = 1;
% for hh = 1:length(data)
%     if ~isequal(data(hh).EPIvsTIRF_s, [])
%         exp(ww) = data(hh).EPIvsTIRF_s;
%         ww = ww + 1;
%     end
% end
% edges = [-5:2:5];
% histogram(exp, edges, 'Normalization', 'probability')

% figure(1)
%  EDGES = [-11.25:2.5:11.25];
%  histogram(cell2mat({data(1:end).EPIvsTIRF_s}), EDGES)
%  xlabel('EPI dis - TIRF dis [s]');
%  ylabel('Frequency [n/total n]');
 
%  EDGES = [-11.25:2.5:11.25];
% load('dz_poz_exp1.mat')
% histogram(cell2mat({a(1:end).EPIvsTIRF_s}), EDGES)
% hold on
% load('dz_neg_exp1.mat')
% histogram(cell2mat({a(1:end).EPIvsTIRF_s}), EDGES)

% figure(2)
%  scatter(cell2mat({data(1:end).lifetime_s}), cell2mat({data(1:end).dzvsCLC_s}))
%  xlabel('CCP lifetime [s]'); ylabel('dz begining time vs clc signal');
%  mdl = fitlm(cell2mat({data(1:end).lifetime_s}), cell2mat({data(1:end).dzvsCLC_s}))
 
% FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
% savefig(FigList, 'dz_poz_exp2.fig')
end

