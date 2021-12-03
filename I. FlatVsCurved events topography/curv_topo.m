% Created by Nawara T. 11/30/21 creates a mask of flat and curved events
% detected by cohort_wrapper.m. The Maks can be then overlayned with the
% live-cell data. Analyze one cell at the time, requiers the cell mask and
% tracks detected by CMEanalysis. Organize data similarly to Nawara et all.
% Sup Fig 9 or 10 to process
% Requiers bioformats package

%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function curv_topo(yourpath)
close all
frame_rate = 0.3;                %frame rate of video
s = 3;                           %signal smotthing range for movmean
f = 5;                           %numbers of positive frame over background to count signal as positive
bel = 3;                         %frames below treshold for dZ channet to begin with
ff = 1;
m = 1; o = 1;
ContentInFold = dir(yourpath); count = 1;
dz_poz_xy = [];
dz_neg_xy = [];

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
                        isequal(tracks(iii).significantSlave(2, 1), 1)
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
                
                if sum(data(n).treshold(1,1:bel))/bel == 0 %mke sure that tracks start from below treshold in CLC channel
                    if sum(data(n).treshold(3,1:bel))/bel == 0 %mke sure that tracks start from below treshold in dZ channel
                        if sum(data(n).treshold(1,end-2:end))/3 == 0 %mke sure that tracks end below treshold in CLC channel
                            if sum(data(n).treshold(3,end-2:end))/3 == 0 %mke sure that tracks send from below treshold in dZ channel
                                if sum(data(n).treshold(3,1:end)) > sum(data(n).treshold(1,1:end))*0.3 %sorting based on dz(+)
                                    dz_poz(o) = data(n);
                                    dz_poz_xy_startend(o,1) = data(n).x_mean_gfp;
                                    dz_poz_xy_startend(o,2) = data(n).y_mean_gfp;
                                    dz_poz_xy_startend(o,3) = data(n).start;
                                    dz_poz_xy_startend(o,4) = data(n).end;
                                    o = o + 1;
                                    
                                elseif  sum(data(n).treshold(3,1:end)) == 0 & std(data(n).A_smooth(3,1:end)) >= -25 & std(data(n).A_smooth(3,1:end)) <= 25 ...
                                        & mean(data(n).A_smooth(3,1:end)) >= -25 & mean(data(n).A_smooth(3,1:end)) <= 25 %sorting based on dz(-)
                                    dz_neg(m) = data(n);
                                    dz_neg_xy_startend(m,1) = data(n).x_mean_gfp;
                                    dz_neg_xy_startend(m,2) = data(n).y_mean_gfp;
                                    dz_neg_xy_startend(m,3) = data(n).start;
                                    dz_neg_xy_startend(m,4) = data(n).end;
                                    m = m + 1;
                                    
                                end
                            end
                        end
                    end
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
            
            
            figure(ff)
            imshow(mask*255); hold on;
            plot(dz_poz_xy_startend(1:end,1), dz_poz_xy_startend(1:end,2), 'go'); hold on
            plot(dz_neg_xy_startend(1:end,1), dz_neg_xy_startend(1:end,2), 'ro'); hold on
            title('Structres distribution | Green - Curved | Red - Flat')
            
            
            masked_events = cell(1000,1);
            frame = 3; spacing = 3;
            
            for ii = 1:length(masked_events)
                masked_events{ii,1} = uint16(zeros(size(mask)));
            end
            
            
            for ii = 1:length(dz_poz_xy_startend)
                x = dz_poz_xy_startend(ii,2);
                y = dz_poz_xy_startend(ii,1);
                
                for zz = dz_poz_xy_startend(ii,3):1:dz_poz_xy_startend(ii,4)
                    masked_events{zz,1}(x-frame:x+frame,y-frame) = 62000;
                    masked_events{zz,1}(x-frame:x+frame,y+frame) = 62000;
                    masked_events{zz,1}(x-frame,y-frame:y+frame) = 62000;
                    masked_events{zz,1}(x+frame,y-frame:y+frame) = 62000;
                end
                
            end
            
            for ii = 1:length(dz_neg_xy_startend)
                x = dz_neg_xy_startend(ii,2);
                y = dz_neg_xy_startend(ii,1);
                for zz = dz_neg_xy_startend(ii,3):1:dz_neg_xy_startend(ii,4)
                    masked_events{zz,1}(x-frame:spacing:x+frame,y-frame) = 62000;
                    masked_events{zz,1}(x-frame:spacing:x+frame,y+frame) = 62000;
                    masked_events{zz,1}(x-frame,y-frame:spacing:y+frame) = 62000;
                    masked_events{zz,1}(x+frame,y-frame:spacing:y+frame) = 62000;
                end
            end
            
            name = [yourpath,'/', 'masked_events_timelapse.tif'];
            cell_mat2tiff(name, masked_events)
            FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
            savefig(FigList, [yourpath, '/', 'Curved_Flat_Topography.fig'])
            
        end
    end
end
%             legend([p1 p2],{'dz(+)' , 'dz(+)'})
%             title('Structres distribution')
%             [size_x, size_y] = size(mask);
%             idx_poz = dbscan(dz_poz_xy,20,6);
%             idx_neg = dbscan(dz_neg_xy,20,6);
%             subplot(1,3,2); gscatter(dz_poz_xy(:,1),dz_poz_xy(:,2),idx_poz); title('DBSCAN on dz(+)'); axis equal; axis ij; legend('off'); axis([0 size_y 0 size_x ]); set(gca,'XTick',[],'YTick',[]); legend('Not in cluster')
%             subplot(1,3,3); gscatter(dz_neg_xy(:,1),dz_neg_xy(:,2),idx_neg); title('DBSCAN on dz(+)'); axis equal; axis ij; legend('off'); axis([0 size_y 0 size_x]); set(gca,'XTick',[],'YTick',[]); legend('Not in cluster')
%
end
%ff= ff +1;
