%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function CCV_vs_FCL_graph_generator(yourpath)

s = 3;                           %signal smotthing range for movmean
bel = 3;                         %frames below treshold for dZ channet to begin with
m = 1; o = 1;

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
            
            %tracks that have significant iRFP and dz,
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
                                    o = o + 1;
                                    
                                elseif  sum(data(n).treshold(3,1:end)) == 0 & std(data(n).A_smooth(3,1:end)) >= -25 & std(data(n).A_smooth(3,1:end)) <= 25 ...
                                        & mean(data(n).A_smooth(3,1:end)) >= -25 & mean(data(n).A_smooth(3,1:end)) <= 25 %sorting based on dz(-)
                                    dz_neg(m) = data(n);
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
            clear('data', 'tracks', 'tracks_sorted', 'dz_poz', 'dz_neg')
        end
    end
    struct_comp_poz(SubFold, ContentInFold(iiiii).name, yourpath);
    struct_comp_neg(SubFold, ContentInFold(iiiii).name, yourpath);
end
total_struct_comp_dz_poz(yourpath);
total_struct_comp_dz_neg(yourpath);

end
