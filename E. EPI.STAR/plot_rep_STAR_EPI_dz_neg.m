function plot_rep_STAR_EPI_dz_neg(data)
X = 1;
f = 3; buf = 6;
    for i = 1:length(data)
        [~, col] = size(data(i).A_smooth);
        for ii = fliplr(1+(f-1):col)
            if sum(data(i).treshold(1,ii-(f-1):ii))/f >= 1
                if X == 1 && ii < col - buf + 1 && data(i).EPIvsTIRF_s >= -1.25 && data(i).EPIvsTIRF_s <= 1.25   
                    rep_488 = data(i).A_smooth(1, ii-buf:ii+buf) + data(i).c_smooth(1, ii-buf:ii+buf);
                    rep_EPI = data(i).A_smooth(4, ii-buf:ii+buf) + data(i).c_smooth(4, ii-buf:ii+buf);
                    rep_dz  = data(i).A_smooth(3, ii-buf:ii+buf) + data(i).c_smooth(3, ii-buf:ii+buf);
                    X = X + 1;
                elseif X > 1 && ii < col - buf + 1 && data(i).EPIvsTIRF_s >= -1.25 && data(i).EPIvsTIRF_s <= 1.25
                    
                    rep_488 = [rep_488; data(i).A_smooth(1, ii-buf:ii+buf) + data(i).c_smooth(1, ii-buf:ii+buf)];
                    rep_EPI = [rep_EPI; data(i).A_smooth(4, ii-buf:ii+buf) + data(i).c_smooth(4, ii-buf:ii+buf)];
                    rep_dz  = [rep_dz; data(i).A_smooth(3, ii-buf:ii+buf) + data(i).c_smooth(3, ii-buf:ii+buf)];
                end
                break
            end
        end
    end
    
norm_rep_488 = normalize(rep_488, 2, 'range');
norm_mean_rep_488 = mean(norm_rep_488);
SEM_norm_rep_488 = std(norm_rep_488)/sqrt(length(norm_rep_488));

norm_rep_EPI = normalize(rep_EPI, 2, 'range');
norm_mean_rep_EPI = mean(norm_rep_EPI);
SEM_norm_rep_EPI = std(norm_rep_EPI)/sqrt(length(norm_rep_EPI));

mean_rep_dz = mean(rep_dz);
SEM_rep_dz = std(rep_dz)/sqrt(length(rep_dz));
length(rep_dz)
         figure(4)
                subplot(2,1,1)
                    errorbar(norm_mean_rep_488, SEM_norm_rep_488, 'c')
                    %ylabel('Normalized inteisty [a.u.]')
%                     set(gca,'xticklabel',[])
%                     set(gca,'yticklabel',[])
                     %xline(7,'r')
                     hold on;
                     axis([0 14 0 1])

                %subplot(3,1,2)
                    errorbar(norm_mean_rep_EPI, SEM_norm_rep_EPI, 'Color', [0.7 0.7 0.7])
                    hold off;


                subplot(2,1,2)
                    errorbar(mean_rep_dz, SEM_rep_dz,  'Color', [1 0.5 0])
                    %ylabel('dz [nm]')
%                     set(gca,'xticklabel',[])
%                     set(gca,'yticklabel',[])
                     %xline(7,'r')
                     axis([0 14 -50 200])


%  FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
%  savefig(FigList,'puncta_sample_030720_Cell2_0.3s_001.fig')
end