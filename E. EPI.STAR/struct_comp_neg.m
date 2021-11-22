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
    
if plots == 1
data = a;

figure(2)
%  EDGES = [-11.25:2.5:11.25];
%  histogram(cell2mat({data(1:end).EPIvsTIRF_s}), EDGES)
%  xlabel('EPI dis - TIRF dis [s]');
%  ylabel('Frequency [n/total n]');
 
%, 'Normalization', 'probability'


 EDGES = [-11.25:2.5:11.25];
 %EDGES = [3*-4.375:1.25:3*6.875];
  %EDGES = [-6.25:2.5:6.25];
  %EDGES = [-5.625:1.25:5.625];
  figure(1)
load('dz_poz_total.mat')
histogram(cell2mat({a(1:end).EPIvsTIRF_s}), EDGES)
figure(2)
load('dz_neg_total.mat')
histogram(cell2mat({a(1:end).EPIvsTIRF_s}), EDGES)


% title('EPI/STAR analysis from 12 cells')
% ylabel('# of events per bin'); xlabel('EPI dis - TIRF dis [s]');
%legend('dz(+) n = 129', 'dz(-) n = 23')

% figure(1)
% load('dz_poz_total.mat')
% data = cell2mat({a(1:end).EPIvsTIRF_s});
% num_bars = 7; %// specify number of bars
% [n, x] = hist(data,num_bars); %// use two-output version of hist to get values
% n_normalized = n/numel(data)/(x(2)-x(1)); %// normalize to unit area
% %bar(x, n_normalized, 1); %// plot histogram (with unit-width bars)
% hold on
% plot(x, n_normalized, 'r'); %// plot line, in red (or change color)
% 
% 
% load('dz_neg_total.mat')
% data = cell2mat({a(1:end).EPIvsTIRF_s});
% num_bars = 7; %// specify number of bars
% [n, x] = hist(data,num_bars); %// use two-output version of hist to get values
% n_normalized = n/numel(data)/(x(2)-x(1)); %// normalize to unit area
% %bar(x, n_normalized, 1); %// plot histogram (with unit-width bars)
% hold on
% plot(x, n_normalized, 'b'); %// plot line, in red (or change color)
% hold off


% figure(2)
%  scatter(cell2mat({data(1:end).lifetime_s}), cell2mat({data(1:end).dzvsCLC_s}))
%  xlabel('CCP lifetime [s]'); ylabel('dz begining time vs clc signal');
%  mdl = fitlm(cell2mat({data(1:end).lifetime_s}), cell2mat({data(1:end).dzvsCLC_s}))
 
% FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
% savefig(FigList, 'dz_neg_exp2.fig')
end
end
