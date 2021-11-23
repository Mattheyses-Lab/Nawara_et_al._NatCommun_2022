%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


function [hh] = Cohort_interpolation_STAR(data, frame_rate, shorter_bound, longer_bound, figure_no, hh)
%hh is a color scaling factor
i = 0;

if nargin < 6 || isempty(hh)
    hh = 0;
end

for ii = 1:length(data)
    if data(ii).lifetime_s >= shorter_bound  && data(ii).lifetime_s < longer_bound
        i = i+1;
        data_coh(i) =  data(ii);
    end
end


if i <= 5
    hh = hh + 0.2;
    fprintf('Cohort %d-%d s contained  %d (5 or less tracks) and will not be ploted \n', shorter_bound, longer_bound, i)
    return
end


data = data_coh;
longer_time = ceil(longer_bound/frame_rate);
data(1).signal_GFP_interpolated = [];
data(1).signal_iRFP_interpolated = [];
data(1).signal_dz_interpolated = [];

for ii = 1:length(data)
    shorter_time = size(data(ii).t, 2);
    shorter_signal_GFP = data(ii).A_smooth(1,1:end); %+ data(ii).c_smooth(1,1:end);
    shorter_signal_iRFP = data(ii).A_smooth(2,1:end); %+ data(ii).c_smooth(2,1:end);
    shorter_signal_dz = data(ii).A_smooth(3,1:end) + data(ii).c_smooth(3,1:end);
    
        shorter_signal_GFP = normalize(shorter_signal_GFP, 'range', [0,1]);
        shorter_signal_iRFP = normalize(shorter_signal_iRFP, 'range', [0,1]);
    
    data(ii).signal_GFP_interpolated = interp1(1:shorter_time, shorter_signal_GFP, linspace(1, shorter_time, longer_time));
    data(ii).signal_iRFP_interpolated = interp1(1:shorter_time, shorter_signal_iRFP, linspace(1, shorter_time, longer_time));
    data(ii).signal_dz_interpolated = interp1(1:shorter_time, shorter_signal_dz, linspace(1, shorter_time, longer_time));
    
end

GFP = zeros(length(data), longer_time);
iRFP = GFP;
dz = GFP;

for ii = 1:length(data)
    GFP(ii, 1:end) = data(ii).signal_GFP_interpolated;
    iRFP(ii, 1:end) = data(ii).signal_iRFP_interpolated;
    dz(ii, 1:end) = data(ii).signal_dz_interpolated;
    
end

mean_GFP = mean(GFP);   std_GFP = std(GFP); SEM_GFP = std_GFP/sqrt(length(data));
mean_iRFP = mean(iRFP); std_iRFP = std(iRFP); SEM_iRFP = std_iRFP/sqrt(length(data));
mean_dz = mean(dz);     std_dz = std(dz); SEM_dz = std_dz/sqrt(length(data));
length(data);

figure(figure_no)
    subplot(3,1,1)
        [r, g, b] = changeSaturation(0,1,1-hh,0.5);
        errorbar(mean_GFP, SEM_GFP, 'Color', ([r, g, b])); hold on;
        pp = plot(mean_GFP, '-', 'LineWidth', 2, 'Color', [0, 1, 1-hh]);
        str = num2str(i);
        text(pp.XData(end)+5, pp.YData(end), str)
        title('Fluorescent signal means/SEMs')
        ylabel('CLCa-...-EGFP [a.u.]')
        axis([0 350 0 1])
        set(gca,'XTick',[])
        hold on 
             
    subplot(3,1,2)
        [r, g, b] = changeSaturation(1, 0, 1-hh,0.5);
        errorbar(mean_iRFP, SEM_iRFP, 'Color', [r, g, b]); hold on;
        plot(mean_iRFP, '-', 'LineWidth', 2, 'Color', [1, 0, 1-hh]);
        ylabel('CLCa-iRFP713-... [a.u.]')
        set(gca,'XTick',[])
        axis([0 350 0 1])

    subplot(3,1,3)
        [r, g, b] = changeSaturation(1, 0.2+hh, 0 ,0.5);
        errorbar(mean_dz, SEM_dz, 'Color', [r, g, b]); hold on
        plot(mean_dz, '-', 'LineWidth', 2, 'Color', [1, 0.2+hh, 0]);
        ylabel('dz [nm]')
        xlabel('Lifetime cohort')
        set(gca,'XTick',[])
        axis([0 350 -50 200])

hh = hh + 0.2;
end

function [r, g, b] = changeSaturation(R,G,B,change)
Pr  = 0.299;
Pg  = 0.587;
Pb  = 0.114;
P=sqrt(R*R*Pr+G*G*Pg+B*B*Pb);
r=P+(R-P)*change;
b=P+(B-P)*change;
g=P+(G-P)*change;

end

% close all
% load([yourpath, '\data_total_dz_poz.mat']) %dz(+)
% hh = Cohort_interpolation_STAR(dz_poz, 0.3, 80, 100, 1);
% hh = Cohort_interpolation_STAR(dz_poz, 0.3, 60, 80, 1, hh);
% hh = Cohort_interpolation_STAR(dz_poz, 0.3, 40, 60, 1, hh);
% hh = Cohort_interpolation_STAR(dz_poz, 0.3, 20, 40, 1, hh);
% Cohort_interpolation_STAR(dz_poz, 0.3, 10, 20, 1, hh);
% load([yourpath, '\data_total_dz_neg']) %dz(-)
% hh = Cohort_interpolation_STAR(dz_neg, 0.3, 80, 100, 2);
% hh = Cohort_interpolation_STAR(dz_neg, 0.3, 60, 80, 2, hh);
% hh = Cohort_interpolation_STAR(dz_neg, 0.3, 40, 60, 2, hh);
% hh = Cohort_interpolation_STAR(dz_neg, 0.3, 20, 40, 2, hh);
% Cohort_interpolation_STAR(dz_neg, 0.3, 10, 20, 2, hh);
