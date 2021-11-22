%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b / calsyfier of endocytic events that passed the
%%% filtering boundaries clasification specs hard coded below


function [data] = my_CME_classifier(data, name)

%Important parameters to set
nuc_limit = -1; % Limit for nucleation in [s]
CCM_limit = 4; % Limit for Constant Curvature model in [s]
CCS_short = 20; % baoudry between short events in [s]
CCS_long = 50; % baoudry between long events in [s]

    try
    structure = evalin('base','structure');
    catch
        structure{1,1} = 'Lifetime';
        structure{2,1} = 'Model';
        structure{1,2} = 'Events'; structure{1,3} =  '<='; structure{1,4} =  sprintf('%is', CCS_short);
        structure{1,5} = 'Events'; structure{1,6} =  'between'; structure{1,7} =  sprintf('%i-%is', CCS_short, CCS_long);
        structure{1,8} = 'Events'; structure{1,9} =  '>'; structure{1,10} =  sprintf('%is', CCS_long);
        structure{2,2} = 'Nuc'; structure{2,3} = 'CCM'; structure{2,4} = 'FTC';
        structure{2,5} = 'Nuc'; structure{2,6} = 'CCM'; structure{2,7} = 'FTC';
        structure{2,8} = 'Nuc'; structure{2,9} = 'CCM'; structure{2,10} = 'FTC';
        structure{1,11} = '% of total # of events';
    end

    [row,~] = size(structure);
    structure{row+1,1} = name;

%% Code runners
class = zeros(length(data),1);
j = 1;
k = 0;
scale_log = 1;

h =  findobj('type','figure');
n = length(h);
%%
if isstruct(data) %for data clasyfication
    for i = 1:length(data)
        if isempty(data(i).dzvsCLC_s)
                class(j) = [];
                k = k + 1;
        elseif data(i).lifetime_s <= CCS_short %Division of CCS into short events
            if data(i).dzvsCLC_s < nuc_limit %Nucleation
                data(i).modelofcruvform = 'Nuc'; 
                class(j) = 1;
                j = j + 1;
            elseif data(i).dzvsCLC_s > CCM_limit %Constant area model
                data(i).modelofcruvform = 'CAM';
                class(j) = 3;
                j = j + 1;
            else
                class(j) = 2; %Constant curvature model
                data(i).modelofcruvform = 'CCM';
                j = j + 1;
            end
            
        elseif data(i).lifetime_s > CCS_short && data(i).lifetime_s <= CCS_long %Division of CCS into long events
            if data(i).dzvsCLC_s < nuc_limit %Nucleation
                data(i).modelofcruvform = 'Nuc';
                class(j) = 4;
                j = j + 1;
            elseif data(i).dzvsCLC_s > CCM_limit %Constant area model
                data(i).modelofcruvform = 'CAM';
                class(j) = 6;
                j = j + 1;
            else
                class(j) = 5; %Constant curvature model
                data(i).modelofcruvform = 'CCM';
                j = j + 1;
            end
            
        elseif data(i).lifetime_s > CCS_long %Division of CCS into long events
            if data(i).dzvsCLC_s < nuc_limit %Nucleation
                data(i).modelofcruvform = 'Nuc';
                class(j) = 7;
                j = j + 1;
            elseif data(i).dzvsCLC_s > CCM_limit %Constant area model
                data(i).modelofcruvform = 'CAM';
                class(j) = 9;
                j = j + 1;
            else
                class(j) = 8; %Constant curvature model
                data(i).modelofcruvform = 'CCM';
                j = j + 1;
            end
        end
    end
    
        if scale_log == 1
          figure(n+1)
            dscatter(cell2mat({data(1:end).lifetime_s}), cell2mat({data(1:end).dzvsCLC_s}),'plottype','scatter')
            xlabel('CCP lifetime [s]'); ylabel('dz begining time vs clc signal [s]'); hold on
            set(gca, 'XScale', 'log');
            yline(nuc_limit,'k--','LineWidth',2)
            yline(CCM_limit,'k--','LineWidth',2)
            xline(CCS_short,'k--','LineWidth',2)
            xline(CCS_long,'k--','LineWidth',2)
            colorbar('FontSize',12);
            colormap(jet);
            axis([5 300 -5 150])

        else
          figure(n+1)
            scatter(cell2mat({data(1:end).lifetime_s}), cell2mat({data(1:end).dzvsCLC_s}),'k.')
            xlabel('CCP lifetime [s]'); ylabel('dz begining time vs clc signal'); hold on

            Lim_x = xlim; Lim_y = ylim;

            [Y,X] = meshgrid(Lim_x(1):1:Lim_x(2), Lim_y(1):0.3:Lim_y(2));
            cls = my_CME_calsifier([X(:),Y(:)]);
            cls = reshape(cls,size(X));
            contour(Y,X, cls==1, log([1,1]),'r--');
            contour(Y,X, cls==2, log([1,1]), 'g--');
            contour(Y,X, cls==3, log([1,1]),'b--');
            hold off;

        end

% else %for countour drawing
%     for i = 1:length(data)
%         if data(i) < nuc_limit
%             class(j) = 1;
%             j = j + 1;
%         elseif data(i) > CCM_limit 
%             class(j) = 3;
%             j = j + 1;
%         else
%             class(j) = 2; %Constant curvature model
%             j = j + 1;
%         end
%     end
end

for jj = 1:length(class)
    if class(jj) == 0
        class = class(1:jj-1);
        break
    end
end
        

%For short events <= CCS_short
pct_tot_nuc = sum(class == 1)/length(class)*100; structure{row+1,2} = pct_tot_nuc;
pct_tot_CCM = sum(class == 2)/length(class)*100; structure{row+1,3} = pct_tot_CCM;
pct_tot_FTC = sum(class == 3)/length(class)*100; structure{row+1,4} = pct_tot_FTC;
n_fast = sum(class == 1) + sum(class == 2) + sum(class == 3);

%For short events <= CCS_fast && > CCS_long
pct_tot_nuc_short = sum(class == 4)/length(class)*100; structure{row+1,5} = pct_tot_nuc_short;
pct_tot_CCM_short = sum(class == 5)/length(class)*100; structure{row+1,6} = pct_tot_CCM_short;
pct_tot_FTC_short = sum(class == 6)/length(class)*100; structure{row+1,7} = pct_tot_FTC_short;
n_short = sum(class == 4) + sum(class == 5) + sum(class == 6);

%For long events  > CCS_long
pct_tot_nuc_long = sum(class == 7)/length(class)*100; structure{row+1,8} = pct_tot_nuc_long;
pct_tot_CCM_long = sum(class == 8)/length(class)*100; structure{row+1,9} = pct_tot_CCM_long;
pct_tot_FTC_long = sum(class == 9)/length(class)*100; structure{row+1,10} = pct_tot_FTC_long;
n_long = sum(class == 7) + sum(class == 8) + sum(class == 9);

assignin('base','structure',structure)

%title(sprintf('Nucleation = %.2f%%, CCM = %.2f%%, FTC = %.2f%%, n = %i', pct_tot_nuc, pct_tot_CCM, pct_tot_FTC,length(class)));
title({[sprintf('Events <= %is, Nuc = %.2f%%, CCM = %.2f%%, FTC = %.2f%%, n = %i', CCS_short, pct_tot_nuc, pct_tot_CCM, pct_tot_FTC, n_fast)]
     [sprintf('Events > %is & <= %is , Nuc = %.2f%%, CCM = %.2f%%, FTC = %.2f%%, n = %i', CCS_short, CCS_long, pct_tot_nuc_short, pct_tot_CCM_short, pct_tot_FTC_short,n_short)]
     [sprintf('Events > %is, Nuc = %.2f%%, CCM = %.2f%%, FTC = %.2f%%, n = %i', CCS_long, pct_tot_nuc_long, pct_tot_CCM_long, pct_tot_FTC_long,n_long)]
     });
 set(gca, 'YTick', unique([nuc_limit, get(gca, 'YTick')]));
 set(gca, 'YTick', unique([CCM_limit, get(gca, 'YTick')]));
 set(gca, 'XTick', unique([CCS_short, get(gca, 'XTick')]));
 set(gca, 'XTick', unique([CCS_long, get(gca, 'XTick')]));
end
