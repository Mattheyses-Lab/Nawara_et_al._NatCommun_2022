%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b to analyze signal to noise ratio data = data_total

function [Nuc_SN, CCM_SN, CAM_SN] = signal2noise_analysis_of_1st_detection_frame(data)

Nuc_SN = []; Nuc_index = 1;
CCM_SN = []; CCM_index = 1;
CAM_SN = []; CAM_index = 1;

models = {'Nuc','CCM','CAM'};
plot = false;

for i = 1:length(data)
    if isequal(data(i).modelofcruvform ,'Nuc') %Nucleation
        Nuc_SN(Nuc_index,1) = data(i).PozDetectionSignal2Noise;
        Nuc_SN(Nuc_index,2) = data(i).PozDetectionSignal2Noise_At_poz_dz;
        Nuc_SN(Nuc_index,3) = data(i).PozDetectionAbsoluteSignal;
        Nuc_SN(Nuc_index,4) = data(i).PozDetectionAbsoluteBackground;
        Nuc_SN(Nuc_index,5) = data(i).PozDetectionAbsoluteSignal_At_poz_dz;
        Nuc_SN(Nuc_index,6) = data(i).PozDetectionAbsoluteBackground_At_poz_dz;
        Nuc_index = Nuc_index + 1;
        
    elseif isequal(data(i).modelofcruvform , 'CCM') %Constant curvatre
        CCM_SN(CCM_index,1) = data(i).PozDetectionSignal2Noise;
        CCM_SN(CCM_index,2) = data(i).PozDetectionSignal2Noise_At_poz_dz;
        CCM_SN(CCM_index,3) = data(i).PozDetectionAbsoluteSignal;
        CCM_SN(CCM_index,4) = data(i).PozDetectionAbsoluteBackground;
        CCM_SN(CCM_index,5) = data(i).PozDetectionAbsoluteSignal_At_poz_dz;
        CCM_SN(CCM_index,6) = data(i).PozDetectionAbsoluteBackground_At_poz_dz;
        CCM_index = CCM_index + 1;
        
    elseif isequal(data(i).modelofcruvform , 'CAM') %Constant area
        CAM_SN(CAM_index,1) = data(i).PozDetectionSignal2Noise;
        CAM_SN(CAM_index,2) = data(i).PozDetectionSignal2Noise_At_poz_dz;
        CAM_SN(CAM_index,3) = data(i).PozDetectionAbsoluteSignal;
        CAM_SN(CAM_index,4) = data(i).PozDetectionAbsoluteBackground;
        CAM_SN(CAM_index,5) = data(i).PozDetectionAbsoluteSignal_At_poz_dz;
        CAM_SN(CAM_index,6) = data(i).PozDetectionAbsoluteBackground_At_poz_dz;
        CAM_index = CAM_index + 1;      
    end
end

if plot == 1 % needs to be optimized for the column to bo analayzed
boxplot(Nuc_SN, 'Positions', 1); hold on;
boxplot(CCM_SN, 'Positions', 2); hold on;
boxplot(CAM_SN, 'Positions', 3); hold off;
set(gca,'XTick',1:3,'XTickLabel',models)
ylim([0 3]);
end


end
        