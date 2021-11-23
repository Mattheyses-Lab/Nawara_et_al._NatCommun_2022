%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


function EPI_STAR_V4(yourpath)

n = 1; m = 1; o = 1; %do not change


show_sample_puncta = false;
frame_rate = 1.25; %frame rate of video
s = 5; %signal smotthing range for movmean
f = 5; %numbers of positive frame over background to count signal as positive
bel = 3; %frames below treshold for dZ channet to begin with

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
            
            %tracks that are CCPs, have significant iRFP and dz,
            %are longer than 5s, are single tracks with valid gaps
            for ii = 1:length(tracks)
                if  tracks(ii).lifetime_s >= 5 && tracks(ii).catIdx == 1 && ...
                        isequal(tracks(ii).significantSlave(2, 1), 1) %&& isequal(tracks(ii).significantSlave(4, 1), 1)
                    tracks_sorted(n) = tracks(ii);
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
                        data(count).t = [tracks_sorted(n).startBuffer.t tracks_sorted(n).t tracks_sorted(n).endBuffer.t];
                        data(count).A_withSbuf = [tracks_sorted(n).startBuffer.A tracks_sorted(n).A tracks_sorted(n).endBuffer.A];
                        data(count).c_withSbuf = [tracks_sorted(n).startBuffer.c tracks_sorted(n).c tracks_sorted(n).endBuffer.c];
                        data(count).sigma_r_withSbuf = [tracks_sorted(n).startBuffer.sigma_r tracks_sorted(n).sigma_r tracks_sorted(n).endBuffer.sigma_r];
                        data(count).lifetime_s = tracks_sorted(n).lifetime_s;
                        data(count).significantSlave = tracks_sorted(n).significantSlave;
                        
                    else
                        data(count).t = tracks_sorted(n).t;
                        data(count).A_withSbuf = tracks_sorted(n).A;
                        data(count).c_withSbuf = tracks_sorted(n).A;
                        data(count).sigma_r_withSbuf = tracks_sorted(n).sigma_r;
                        data(count).lifetime_s = tracks_sorted(n).lifetime_s;
                        data(count).significantSlave = tracks_sorted(n).significantSlave;
                    end
                    
                    data(count).x_mean_gfp = round(mean(tracks_sorted(n).x(1,1:end)));
                    data(count).y_mean_gfp = round(mean(tracks_sorted(n).y(1,1:end)));
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
                data(n).A_smooth(4, 1:end) = movmean(data(n).A_withSbuf(4, 1:end),s);
                
                data(n).c_smooth = movmean(data(n).c_withSbuf(1, 1:end),s);
                data(n).c_smooth(2, 1:end) = movmean(data(n).c_withSbuf(2, 1:end),s);
                data(n).c_smooth(3, 1:end) = movmean(data(n).c_withSbuf(3, 1:end),s);
                data(n).c_smooth(4, 1:end) = movmean(data(n).c_withSbuf(4, 1:end),s);
                
                data(n).sigma_r_smooth = movmean(data(n).sigma_r_withSbuf(1, 1:end),s);
                data(n).sigma_r_smooth(2, 1:end) = movmean(data(n).sigma_r_withSbuf(2, 1:end),s);
                data(n).sigma_r_smooth(3, 1:end) = movmean(data(n).sigma_r_withSbuf(3, 1:end),s);
                data(n).sigma_r_smooth(4, 1:end) = movmean(data(n).sigma_r_withSbuf(4, 1:end),s);
                
                [row, col] = size(data(n).A_smooth);
                
                %creation of matirxes when signal is higer than treshold
                for jj = 1:col
                    for ii = 1:row-1
                        if (data(n).A_withSbuf(ii,jj) + data(n).c_withSbuf(ii,jj)) > (2*data(n).sigma_r_withSbuf(ii,jj) + data(n).c_withSbuf(ii,jj))
                            data(n).treshold(ii,jj) = 1;
                        else
                            data(n).treshold(ii,jj) = 0;
                        end
                    end
                    
                    for ii = 4 %this is the EPI channel only here we saw that 2STD are to high fro signal detection
                        if (data(n).A_withSbuf(ii,jj) + data(n).c_withSbuf(ii,jj)) > (data(n).sigma_r_withSbuf(ii,jj) + data(n).c_withSbuf(ii,jj))
                            data(n).treshold(ii,jj) = 1;
                        else
                            data(n).treshold(ii,jj) = 0;
                        end
                    end
                    
                end
                
                %                         %EPI signal is very noisy this step assures a high quality of traces
                %                         if abs(sum(data(n).treshold(1,round(end/2):end-3))-sum(data(n).treshold(4,round(end/2):end-3))) > 3
                %                             data(n).TIRF_down_s = [];
                %                             data(n).EPI_down_s = [];
                %                             data(n).EPIvsTIRF_s = [];
                %
                %
                %                         %pick only high quality traces
                %                         elseif sum(data(n).treshold(1,1:end))*0.70 > sum(data(n).treshold(2,1:end))
                %                             data(n).TIRF_down_s = [];
                %                             data(n).EPI_down_s = [];
                %                             data(n).EPIvsTIRF_s = [];
                %
                %                         elseif sum(data(n).treshold(1,1:end))*0.90 > sum(data(n).treshold(4,1:end))
                %                             data(n).TIRF_down_s = [];
                %                             data(n).EPI_down_s = [];
                %                             data(n).EPIvsTIRF_s = [];
                %
                %
                %
                %                         else
                
                data(n).TIRF_down_s = [];
                data(n).EPI_down_s = [];
                data(n).EPIvsTIRF_s = [];
                
                if sum(data(n).treshold(1,1:end))*0.60 > sum(data(n).treshold(2,1:end))
                    data(n).TIRF_down_s = [];
                    data(n).EPI_down_s = [];
                    data(n).EPIvsTIRF_s = [];
                    
%                 elseif sum(data(n).treshold(1,1:end))*0.50 > sum(data(n).treshold(4,1:end))
%                     data(n).TIRF_down_s = [];
%                     data(n).EPI_down_s = [];
%                     data(n).EPIvsTIRF_s = [];
                    
                    %discarding the tracks that does not disaper from epi within last three
                    %frames
                elseif sum(data(n).treshold(4,end-2:end))/3 >= 1
                    data(n).TIRF_down_s = [];
                    data(n).EPI_down_s = [];
                    data(n).EPIvsTIRF_s = [];
                    
                    
                    
                    
                else
                    if sum(data(n).treshold(1,1:bel))/bel == 0 %mke sure that tracks start from below treshold in CLC channel
                        if sum(data(n).treshold(3,1:bel))/bel == 0 %mke sure that tracks start from below treshold in dZ channel
                            if sum(data(n).treshold(4,1:bel))/bel == 0 % same for epi
                                
                                for ii = fliplr(1+f:col)
                                    if sum(data(n).treshold(1,ii-(f-1):ii))/f >= 1
                                        data(n).TIRF_down_s = (ii)*frame_rate;
                                        break
                                    else
                                        data(n).TIRF_down_s = [];
                                        data(n).EPIvsTIRF_s = [];
                                    end
                                end
                                
                                for ii = fliplr(1+f:col)
                                    if sum(data(n).treshold(4,ii-(f-1):ii))/f >= 1
                                        data(n).EPI_down_s = (ii)*frame_rate;
                                        break
                                    else
                                        data(n).EPI_down_s = [];
                                        data(n).EPIvsTIRF_s = [];
                                    end
                                end
                                
                                data(n).EPIvsTIRF_s = data(n).EPI_down_s -  data(n).TIRF_down_s;
                            else
                                data(n).TIRF_down_s = [];
                                data(n).EPI_down_s = [];
                                data(n).EPIvsTIRF_s = [];
                            end
                        else
                            data(n).TIRF_down_s = [];
                            data(n).EPI_down_s = [];
                            data(n).EPIvsTIRF_s = [];
                        end
                    else
                        data(n).TIRF_down_s = [];
                        data(n).EPI_down_s = [];
                        data(n).EPIvsTIRF_s = [];
                    end
                    
                end
                
                %     plot((data(n).A_withSbuf(1, 1:end)))
                %                     hold on
                %                 plot((data(n).A_withSbuf(4, 1:end)))
                %                 plot((data(n).A_withSbuf(3, 1:end)))
                %                 %if ~isempty(EPI_peaks)
                %                 xline(data(n).EPI_down_s/frame_rate)
                %                 %end
                %                 %xline(EPI_dif)
                %                 %if ~isempty(TIRF_peaks)
                %                 xline(data(n).TIRF_down_s/frame_rate, '--')
                %                 %end
                %                 close all
                %
                %     if isempty(data(n).dzvsCLC_s) || isempty(data(n).dz_s)
                %         data(n).lifetime_s = [];
                %     end
            end
            
            
            for ii = 1:length(data)
                if isequal(data(ii).significantSlave(3, 1), 1) & data(ii).EPIvsTIRF_s <= 11.25 & data(ii).EPIvsTIRF_s >= -11.25 %& sum(data(ii).treshold(1,end-(f-1):end))/5 == 0
                    dz_poz(o) = data(ii);
                    o = o + 1;
                    
                elseif isequal(data(ii).significantSlave(3, 1), 0) & mean(data(ii).A_smooth(3,1:end)) >= -25 & mean(data(ii).A_smooth(3,1:end)) <= 25 & data(ii).EPIvsTIRF_s <= 11.25 & data(ii).EPIvsTIRF_s >= -11.25
                    dz_neg(m) = data(ii);
                    m = m + 1;
                    
                end
            end
            o = 1; m = 1;
            
            name_dz_poz = [ContentInSubFold(iiii).folder, '/', ContentInSubFold(iiii).name(1:end-10),'dz_poz.mat'];
            name_dz_neg = [ContentInSubFold(iiii).folder, '/', ContentInSubFold(iiii).name(1:end-10),'dz_neg.mat'];
            
            if exist('dz_poz','var') && exist('dz_neg', 'var')
                save(name_dz_poz, 'dz_poz')
                save(name_dz_neg, 'dz_neg')
            elseif exist('dz_poz', 'var') && ~exist('dz_neg', 'var')
                save(name_dz_poz, 'dz_poz')
            elseif ~exist('dz_poz', 'var') && exist('dz_neg', 'var')
                save(name_dz_neg, 'dz_neg')
            end
            
            
            
            %dz vs CLC hisotgram and scater plot generation (includid statictics)
            %  EDGES = [-10:1:10];
            % figure(1)
            %  histogram(cell2mat({dz_poz(1:end).EPIvsTIRF_s}), EDGES)
            %  xlabel('EPI-TIRF');
            %  ylabel('Frequency');
            % figure(2)
            %  histogram(cell2mat({dz_neg(1:end).EPIvsTIRF_s}), EDGES)
            %  xlabel('EPI-TIRF');
            %  ylabel('Frequency');
            % %
            % FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
            % savefig(FigList, name_fig)
            
            %chech of raw vs smooth data multiple plot
            if show_sample_puncta == 1
                for i = 3:50:length(data)
                    figure(i)
                    subplot(3,1,1)
                    plot(data(i).A_smooth(1, 1:end) + data(i).c_smooth(1, 1:end)); hold on; ...
                        plot(data(i).c_smooth(1, 1:end)); hold on; ...
                        plot(data(i).c_smooth(1, 1:end) + 2*data(i).sigma_r_smooth(1, 1:end))
                    ylim([min(data(i).c_withSbuf(1, 1:end)) max((data(i).A_withSbuf(1, 1:end) + data(i).c_withSbuf(1, 1:end)))])
                    title('CMEanalysis detection')
                    ylabel('CLC-...-EGFP [a.u.]')
                    title('movmean of',s)
                    xline(15,'r')
                    subplot(3,1,2)
                    plot(data(i).A_withSbuf(4, 1:end) + data(i).c_withSbuf(4, 1:end)); hold on; ...
                        plot(data(i).c_withSbuf(4, 1:end)); hold on; ...
                        plot(data(i).c_withSbuf(4, 1:end) + 2*data(i).sigma_r_withSbuf(4, 1:end))
                    ylim([min(data(i).c_withSbuf(4, 1:end)) max((data(i).A_withSbuf(4, 1:end) + data(i).c_withSbuf(4, 1:end)))])
                    ylabel('dz [nm]')
                    xlabel('frames')
                    xline(15,'r')
                    subplot(3,1,3)
                    plot(data(i).A_smooth(3, 1:end) + data(i).c_smooth(3, 1:end)); hold on; ...
                        plot(data(i).c_smooth(3, 1:end)); hold on; ...
                        plot(data(i).c_smooth(3, 1:end) + 2*data(i).sigma_r_smooth(3, 1:end))
                    ylim([min(data(i).c_withSbuf(3, 1:end)) max((data(i).A_withSbuf(3, 1:end) + data(i).c_withSbuf(3, 1:end)))])
                    ylabel('EPI [a.u.]')
                    xlabel('frames')
                    xline(15,'r')
                end
                FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
                savefig(FigList,'puncta_sample_030720_Cell2_0.3s_001.fig')
            end
            close all
            clear('data', 'tracks', 'tracks_sorted', 'dz_poz', 'dz_neg')
            %data = [a.data, b.data] %combining the structures into one structure needs
            %optimization
        end
    end
    struct_comp_poz(SubFold, ContentInFold(iiiii).name, yourpath);
    struct_comp_neg(SubFold, ContentInFold(iiiii).name, yourpath);
end
total_struct_comp_dz_poz(yourpath);
total_struct_comp_dz_neg(yourpath);
end

%FOR PLOTTING
% EDGES = [-11.25:2.5:11.25];
%  histogram(cell2mat({data(1:end).EPIvsTIRF_s}), EDGES)
%         xlabel('EPI - TIRF disapearance [s]');
%         ylabel('Frequency');
     
