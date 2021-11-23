%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b / this is the fuction that calculates the difference bwteeen dz and CLC in s
%%% and outputs the figures as well as the data matrixes
%%% it filters the tracks and so on details in the body

%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


function dz_beginning(yourpath)


close all
show_sample_puncta = false;
show_discard = false;
frame_rate = 0.3;                %frame rate of video
s = 3;                           %signal smotthing range for movmean
f = 5;                           %numbers of positive frame over background to count signal as positive
bel = 3;                         %frames below treshold for dZ channet to begin with

% Signal to Noise analysis of first detection frame vs model


ContentInFold = dir(yourpath);
count = 1;

    for iiiii = 3:length(ContentInFold)
        SubFold = [ContentInFold(iiiii).folder, '/', ContentInFold(iiiii).name];
        ContentInSubFold = dir(SubFold);
        
        for iiii = 3:length(ContentInSubFold)
            if strfind(ContentInSubFold(iiii).name, 'Tracks') >= 1
                path2tracks = [ContentInSubFold(iiii).folder, '/', ContentInSubFold(iiii).name];
                path2mask = [path2tracks(1:end-10) 'Mask.tif'];
                load(path2tracks)
                mask = imread(path2mask);
                n = 1; %do not change
         
                % have significant iRFP and dz, 
                %are longer than 5s, are single tracks with valid gaps
                for iii = 1:length(tracks)
                    if  tracks(iii).lifetime_s >= 5 && tracks(iii).catIdx == 1 && ...
                             isequal(tracks(iii).significantSlave(2:3, 1), [1; 1])
                        tracks_sorted(n) = tracks(iii);
                        n = n + 1;
                    end
                end

                clear('tracks') %for memory

                %Merging detection with the start buffer if exist and reducing the size
                %of the oryginal tracks detection
                for n = 1:length(tracks_sorted)                  
                    x_mean_gfp = round(mean(tracks_sorted(n).x(1,1:end)));
                    y_mean_gfp = round(mean(tracks_sorted(n).y(1,1:end)));
                    
                    if mask(y_mean_gfp, x_mean_gfp) == 1 %to check if the track is withinin cell mask otherwise discard track
                        
                        if ~isequal(tracks_sorted(n).startBuffer.A, [])
                            data(count).t = [tracks_sorted(n).startBuffer.t tracks_sorted(n).t];
                            data(count).A_withSbuf = [tracks_sorted(n).startBuffer.A tracks_sorted(n).A];
                            data(count).c_withSbuf = [tracks_sorted(n).startBuffer.c tracks_sorted(n).c];
                            data(count).sigma_r_withSbuf = [tracks_sorted(n).startBuffer.sigma_r tracks_sorted(n).sigma_r];
                            data(count).lifetime_s = tracks_sorted(n).lifetime_s;

                        else
                            data(count).t = tracks_sorted(n).t;
                            data(count).A_withSbuf = tracks_sorted(n).A;
                            data(count).c_withSbuf = tracks_sorted(n).A;
                            data(count).sigma_r_withSbuf = tracks_sorted(n).sigma_r;
                            data(count).lifetime_s = tracks_sorted(n).lifetime_s;
                        end
                    
                    data(count).x_mean_gfp = round(mean(tracks_sorted(n).x(1,1:end)));
                    data(count).y_mean_gfp = round(mean(tracks_sorted(n).y(1,1:end)));
                    data(count).GAP_frames = tracks_sorted(n).gapIdx;
                    count = count + 1;
                    end

                end
                count = 1;
                clear('tracks_sorted') %for memory

                %smoothing of the data the amplitudes, backgroung and std of the
                %background

                for n = 1:length(data)
                    data(n).A_smooth = movmean(data(n).A_withSbuf(1, 1:end),s);
                    data(n).A_smooth(2, 1:end) = movmean(data(n).A_withSbuf(2, 1:end),s);
                    data(n).A_smooth(3, 1:end) = movmean(data(n).A_withSbuf(3, 1:end),s);

                    data(n).c_smooth = movmean(data(n).c_withSbuf(1, 1:end),s);
                    data(n).c_smooth(2, 1:end) = movmean(data(n).c_withSbuf(2, 1:end),s);
                    data(n).c_smooth(3, 1:end) = movmean(data(n).c_withSbuf(3, 1:end),s);

                    data(n).sigma_r_smooth = movmean(data(n).sigma_r_withSbuf(1, 1:end),s);
                    data(n).sigma_r_smooth(2, 1:end) = movmean(data(n).sigma_r_withSbuf(2, 1:end),s);
                    data(n).sigma_r_smooth(3, 1:end) = movmean(data(n).sigma_r_withSbuf(3, 1:end),s);

                    [row, col] = size(data(n).A_smooth);
                    
                    %creation of matirxes when signal is higer than treshold
                    for jj = 1:col
                        for ii = 1:row
                            if (data(n).A_smooth(ii,jj) + data(n).c_smooth(ii,jj)) > (2*data(n).sigma_r_smooth(ii,jj) + data(n).c_smooth(ii,jj))
                                data(n).treshold(ii,jj) = 1;
                            else
                                data(n).treshold(ii,jj) = 0;
                            end
                        end
                    end
  

                    %looking for dZ being positive in n constitutive frames
                    for ii = 1:col-(f-1)
                        if sum(data(n).treshold(3,1:bel))/bel == 0 %mke sure that tracks start from below treshold in dZ channel
                            if sum(data(n).treshold(3,ii:ii+(f-1)))/f >= 1
                                data(n).PozDetectionSignal2Noise_At_poz_dz = (data(n).A_smooth(1,ii-1) + data(n).c_smooth(1,ii-1))/data(n).c_smooth(1,ii-1);
                                data(n).PozDetectionAbsoluteSignal_At_poz_dz = (data(n).A_smooth(1,ii-1) + data(n).c_smooth(1,ii-1));
                                data(n).PozDetectionAbsoluteBackground_At_poz_dz = data(n).c_smooth(1,ii-1);
                                data(n).dz_s = (ii-1)*frame_rate;
                                break
                            else
                                data(n).dz_s = [];
                                data(n).PozDetectionSignal2Noise_At_poz_dz = [];
                                data(n).PozDetectionAbsoluteSignal_At_poz_dz = [];
                                data(n).PozDetectionAbsoluteBackground_At_poz_dz = [];
                            end
                        else
                            data(n).dz_s = [];
                            data(n).PozDetectionSignal2Noise_At_poz_dz = [];
                            data(n).PozDetectionAbsoluteSignal_At_poz_dz = [];
                            data(n).PozDetectionAbsoluteBackground_At_poz_dz = [];
                        end
                    end
    
                    for ii = 1:col-(f-1)
                        if sum(data(n).treshold(1,1:3))/3 == 0 %mke sure that tracks start from below treshold in CLC channel
                            if sum(data(n).treshold(1,ii:ii+(f-1)))/f >= 1
                                data(n).CLC_s = (ii-1)*frame_rate;
                                data(n).PozDetectionSignal2Noise = (data(n).A_smooth(1,ii-1) + data(n).c_smooth(1,ii-1))/data(n).c_smooth(1,ii-1);
                                data(n).PozDetectionAbsoluteSignal = (data(n).A_smooth(1,ii-1) + data(n).c_smooth(1,ii-1));
                                data(n).PozDetectionAbsoluteBackground = data(n).c_smooth(1,ii-1);
                                break
                            else
                                data(n).CLC_s = [];
                                data(n).PozDetectionSignal2Noise = [];
                                data(n).PozDetectionAbsoluteSignal = [];
                                data(n).PozDetectionAbsoluteBackground = [];
                                
                            end
                        else
                            data(n).CLC_s = [];
                            data(n).PozDetectionSignal2Noise = [];
                            data(n).PozDetectionAbsoluteSignal = [];
                            data(n).PozDetectionAbsoluteBackground = [];
                            
                        end
                    end
                    
                    if sum(data(n).treshold(1,1:end))*0.7 > sum(data(n).treshold(2,1:end))
                        data(n).dz_s = [];
                        data(n).CLC_s = [];
                        data(n).dzvsCLC_s = [];
                        
                        if show_discard == 1
                        i = n;
                        figure(i)
                        subplot(3,1,1)
                                plot(data(i).A_smooth(1, 1:end) + data(i).c_smooth(1, 1:end)); hold on; ...
                                plot(data(i).c_smooth(1, 1:end)); hold on; ...
                                plot(data(i).c_smooth(1, 1:end) + 2*data(i).sigma_r_smooth(1, 1:end))
                                ylim([min(data(i).c_withSbuf(1, 1:end)) max((data(i).A_withSbuf(1, 1:end) + data(i).c_withSbuf(1, 1:end)))])
                                title('GFP')
                                xline(15,'r')
                            subplot(3,1,2)
                                plot(data(i).A_smooth(2, 1:end) + data(i).c_smooth(2, 1:end)); hold on; ...
                                plot(data(i).c_smooth(2, 1:end)); hold on; ...
                                plot(data(i).c_smooth(2, 1:end) + 2*data(i).sigma_r_smooth(2, 1:end))
                                ylim([min(data(i).c_withSbuf(2, 1:end)) max((data(i).A_withSbuf(2, 1:end) + data(i).c_withSbuf(2, 1:end)))])
                                title('iRFP')
                                xline(15,'r')
                            subplot(3,1,3)
                                plot(data(i).A_smooth(3, 1:end) + data(i).c_withSbuf(3, 1:end)); hold on; ...
                                plot(data(i).c_smooth(3, 1:end)); hold on; ...
                                plot(data(i).c_smooth(3, 1:end) + 2*data(i).sigma_r_withSbuf(3, 1:end))
                                ylim([min(data(i).c_smooth(3, 1:end)) max((data(i).A_smooth(3, 1:end) + data(i).c_smooth(3, 1:end)))])
                                ylabel('dz [nm]')
                                xlabel('frames')
                                xline(15,'r')
                        end
                            
                        
                    else
                        data(n).dzvsCLC_s = data(n).dz_s - data(n).CLC_s;
                    end
   
                    if isempty(data(n).dzvsCLC_s) || isempty(data(n).dz_s)
                        data(n).lifetime_s = [];
                    end
        
                end
                
                name_mat = [ContentInSubFold(iiii).folder, '/', ContentInSubFold(iiii).name(1:end-10), 'dzvsCLC.mat'];
                save(name_mat, 'data')
                
                %chech of raw vs smooth data multiple plot
                 if show_sample_puncta == 1
                    for FFF = 3:50:length(data)
                        figure(i)
                            subplot(2,2,1)
                                plot(data(i).A_withSbuf(1, 1:end) + data(i).c_withSbuf(1, 1:end)); hold on; ...
                                plot(data(i).c_withSbuf(1, 1:end)); hold on; ...
                                plot(data(i).c_withSbuf(1, 1:end) + 2*data(i).sigma_r_withSbuf(1, 1:end))
                                ylim([min(data(i).c_withSbuf(1, 1:end)) max((data(i).A_withSbuf(1, 1:end) + data(i).c_withSbuf(1, 1:end)))])
                                title('CMEanalysis detection')
                                ylabel('CLC-...-EGFP [a.u.]')
                                xline(15,'r')
                            subplot(2,2,2)
                                plot(data(i).A_smooth(1, 1:end) + data(i).c_smooth(1, 1:end)); hold on; ...
                                plot(data(i).c_smooth(1, 1:end)); hold on; ...
                                plot(data(i).c_smooth(1, 1:end) + 2*data(i).sigma_r_smooth(1, 1:end))
                                ylim([min(data(i).c_withSbuf(1, 1:end)) max((data(i).A_withSbuf(1, 1:end) + data(i).c_withSbuf(1, 1:end)))])
                                title('movmean of',s)
                                xline(15,'r')
                            subplot(2,2,3)
                                plot(data(i).A_withSbuf(3, 1:end) + data(i).c_withSbuf(3, 1:end)); hold on; ...
                                plot(data(i).c_withSbuf(3, 1:end)); hold on; ...
                                plot(data(i).c_withSbuf(3, 1:end) + 2*data(i).sigma_r_withSbuf(3, 1:end))
                                ylim([min(data(i).c_withSbuf(3, 1:end)) max((data(i).A_withSbuf(3, 1:end) + data(i).c_withSbuf(3, 1:end)))])
                                ylabel('dz [nm]')
                                xlabel('frames')
                                xline(15,'r')
                            subplot(2,2,4)
                                plot(data(i).A_smooth(3, 1:end) + data(i).c_smooth(3, 1:end)); hold on; ...
                                plot(data(i).c_smooth(3, 1:end)); hold on; ...
                                plot(data(i).c_smooth(3, 1:end) + 2*data(i).sigma_r_smooth(3, 1:end))
                                ylim([min(data(i).c_withSbuf(3, 1:end)) max((data(i).A_withSbuf(3, 1:end) + data(i).c_withSbuf(3, 1:end)))])
                                xlabel('frames')
                                xline(15,'r')
                    end

                    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
                    savefig(FigList,'puncta_sample_030720_Cell2_0.3s_001.fig')
                 end
                 close all
                 clear('data')
            end
        end  
        struct_comp(SubFold, ContentInFold(iiiii).name, yourpath);    
    end
    total_struct_comp(yourpath)
    structure = evalin('base','structure');
    name_struct = [yourpath, 'modelsVSlifetime_cohort.mat'];
    save(name_struct, 'structure')
end
