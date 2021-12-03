% Created by Nawara T. 11/30/21 creates a mask of evnets classifictation
% Nuc - small dotted square, CCM - big full square, FTC - bigf dotted
% square
% detected by cohort_wrapper.m. The Maks can be then overlayned with the
% live-cell data. Analyze one cell at the time, requiers the cell mask and
% tracks detected by CMEanalysis. Organize data similarly to Nawara et all.
% Sup Fig 9 or 10 to process
% Requiers bioformats package

%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


function Topo_of_model(yourpath)
close all
frame_rate = 0.3;                %frame rate of video
s = 3;                           %signal smotthing range for movmean
f = 5;                           %numbers of positive frame over background to count signal as positive
bel = 3;                         %frames below treshold for dZ channet to begin with
ff = 1;
m = 1; 
ContentInFold = dir(yourpath); count = 1;
xy_startend = [];
nuc_limit = -1; % Limit for nucleation in [s]
CCM_limit = 4; % Limit for Constant Curvature model in [s]

for iiiii = 3:length(ContentInFold)
    SubFold = [ContentInFold(iiiii).folder, '/', ContentInFold(iiiii).name];
    ContentInSubFold = dir(SubFold);
    
    for iiii = 3:length(ContentInSubFold)
        if strfind(ContentInSubFold(iiii).name, 'Tracks') >= 1
            path2tracks = [ContentInSubFold(iiii).folder, '/', ContentInSubFold(iiii).name];
            load(path2tracks)
            path2mask = [path2tracks(1:end-10) 'Mask.tif'];
            load(path2tracks)
            mask = imread(path2mask);
            n = 1; %do not change
            
            %tracks that are CCPs, have significant iRFP and dz,
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
                    data(count).start = tracks_sorted(n).start;
                    data(count).end = tracks_sorted(n).end;
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
                    
                else
                    data(n).dzvsCLC_s = data(n).dz_s - data(n).CLC_s;
                    if ~isempty(data(n).dzvsCLC_s)
                        xy_startend(m,1) = data(n).x_mean_gfp;
                        xy_startend(m,2) = data(n).y_mean_gfp;
                        xy_startend(m,3) = data(n).start;
                        xy_startend(m,4) = data(n).end;
                        xy_startend(m,5) = data(n).dzvsCLC_s;
                        m = m + 1;
                    end
                end
                
                if isempty(data(n).dzvsCLC_s) || isempty(data(n).dz_s)
                    data(n).lifetime_s = [];
                end
                
            end
            
        
        
        %o = 1; m = 1;
        
        %             name_dz_poz = [ContentInSubFold(iiii).folder, '/', ContentInSubFold(iiii).name(1:end-10),'dz_poz.mat'];
        %             name_dz_neg = [ContentInSubFold(iiii).folder, '/', ContentInSubFold(iiii).name(1:end-10),'dz_neg.mat'];
        %
        %             if exist('dz_poz','var') && exist('dz_neg', 'var')
        %                 save(name_dz_poz, 'dz_poz')
        %                 save(name_dz_neg, 'dz_neg')
        %             elseif exist('dz_poz', 'var') && ~exist('dz_neg', 'var')
        %                 save(name_dz_poz, 'dz_poz')
        %             elseif ~exist('dz_poz', 'var') && exist('dz_neg', 'var')
        %                 save(name_dz_neg, 'dz_neg')
        %             end
        
        
        figure(ff)
        imshow(mask*255); hold on;
        
        title('Nuc - Blue | Green - CCM | Red - FTC')
        
        
        masked_events = cell(1000,1);
        %frame = 3; spacing = 3;
        
        for ii = 1:length(masked_events)
            masked_events{ii,1} = uint16(zeros(size(mask)));
        end
        
        
        for ii = 1:length(xy_startend)
            x = xy_startend(ii,2);
            y = xy_startend(ii,1);
            
            for zz = xy_startend(ii,3):1:xy_startend(ii,4)
                if xy_startend(ii,5) < nuc_limit %Nucleation
                    frame = 2; spacing = 2;
                    masked_events{zz,1}(x-frame:spacing:x+frame,y-frame) = 62000;
                    masked_events{zz,1}(x-frame:spacing:x+frame,y+frame) = 62000;
                    masked_events{zz,1}(x-frame,y-frame:spacing:y+frame) = 62000;
                    masked_events{zz,1}(x+frame,y-frame:spacing:y+frame) = 62000;
                    plot(y, x, 'b*'); hold on;
                    
                elseif xy_startend(ii,5) > CCM_limit %FTC
                    frame = 3; spacing = 3;
                    masked_events{zz,1}(x-frame:spacing:x+frame,y-frame) = 62000;
                    masked_events{zz,1}(x-frame:spacing:x+frame,y+frame) = 62000;
                    masked_events{zz,1}(x-frame,y-frame:spacing:y+frame) = 62000;
                    masked_events{zz,1}(x+frame,y-frame:spacing:y+frame) = 62000;
                    plot(y, x, 'r*'); hold on;
                    
                else %CCM
                    frame = 3;
                    masked_events{zz,1}(x-frame:x+frame,y-frame) = 62000;
                    masked_events{zz,1}(x-frame:x+frame,y+frame) = 62000;
                    masked_events{zz,1}(x-frame,y-frame:y+frame) = 62000;
                    masked_events{zz,1}(x+frame,y-frame:y+frame) = 62000;
                    plot(y, x, 'g*'); hold on;
                    
                end
                
            end
        end
        
        %     EDGES = [-5.5:1:100];
        %     histogram(xy_startend(1:end,5), EDGES)
        
        name = [yourpath, '/', 'masked_events_timelapse.tif'];
        cell_mat2tiff(name, masked_events)
        FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
        savefig(FigList, [yourpath, '/', 'Models_Topography.fig'])
        close all
        
    end
end
end

