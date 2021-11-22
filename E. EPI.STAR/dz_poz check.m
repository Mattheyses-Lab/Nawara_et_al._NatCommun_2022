            
for i = 1:5:(size(dz_poz,2))
    figure(i)
subplot(3,1,1)
                plot(dz_poz(i).A_smooth(1, 1:end) + dz_poz(i).c_smooth(1, 1:end)); hold on; ...
                plot(dz_poz(i).c_smooth(1, 1:end)); hold on; ...
                plot(dz_poz(i).c_smooth(1, 1:end) + 2*dz_poz(i).sigma_r_smooth(1, 1:end))
                ylim([min(dz_poz(i).c_smooth(1, 1:end)) max((dz_poz(i).A_smooth(1, 1:end) + dz_poz(i).c_smooth(1, 1:end)))])
                title('CMEanalysis detection')
                ylabel('CLC-...-EGFP [a.u.]')

            subplot(3,1,2)
                plot(dz_poz(i).A_smooth(4, 1:end) + dz_poz(i).c_smooth(4, 1:end)); hold on; ...
                plot(dz_poz(i).c_smooth(4, 1:end)); hold on; ...
                plot(dz_poz(i).c_smooth(4, 1:end) + 2*dz_poz(i).sigma_r_smooth(4, 1:end))
                ylim([min(dz_poz(i).c_smooth(4, 1:end)) max((dz_poz(i).A_smooth(4, 1:end) + dz_poz(i).c_smooth(4, 1:end)))])
                ylabel('EPI [a.u.]')
                xlabel('frames')

            subplot(3,1,3)
                plot(dz_poz(i).A_smooth(3, 1:end) + dz_poz(i).c_smooth(3, 1:end)); hold on; ...
                plot(dz_poz(i).c_smooth(3, 1:end)); hold on; ...
                plot(dz_poz(i).c_smooth(3, 1:end) + 2*dz_poz(i).sigma_r_smooth(3, 1:end))
                ylim([min(dz_poz(i).c_smooth(3, 1:end)) max((dz_poz(i).A_smooth(3, 1:end) + dz_poz(i).c_smooth(3, 1:end)))])
                ylabel('dz [nm]')
                xlabel('frames')
end