%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function IMGREG(yourpath, Grid_488_raw, Grid_647_reg, use_fixed_detection)
%%% Created by Nawara T. Matttheyses Lab @UAB 03.02.20
%IMREG is a fucntion that allows to register multichannel image stack,
%based on the calibration grid. it needs 7 types of imputs:
% 1. Path to the referance grid picture [path488];
% 2. Path to to be registered grid picture [path647];
% 3. Path to the image or image stack to be registered [pathdata_reg];
% 4. Path to the referance image or image stack [pathdata_ref];
% 5. Specifed sigma for Gausian filtering
% 6. Defined 'FilterSize'/f for feature detection
% 7. Name a of the file to be saved
% Program requires instalation of bio-formats tool box details:
% https://docs.openmicroscopy.org/bio-formats/6.4.0/users/matlab/index.html
% Requires Computer Vision Toolbox
% For any qestions email tomasz.nawara.95@gmail.com

%[last edited:11.10.20]
%  Fixed error in how detected points were saved in matrix [04.26.20]
%  Fixed image display [04.27.20]
%  Added the registration conformation window (figure 1) [05.05.20]
%  Added Registration of signle frame images [07.04.20]
%  Added batch processing [10.09.20]
%  Added batch processing for single images [11.10.20]

sigma = 3;
f = 11;
zz = 0;
what_a_day_to_code = 0;
dbstop in IMGREG at 124 if m=='N'

if use_fixed_detection == 0
    
    %Apply Gausian smotching to pictures
    I488 = imgaussfilt(Grid_488_raw, sigma);
    I647 = imgaussfilt(Grid_647_reg, sigma);
    
    %Use bfopen to load the data
    I = size(Grid_488_raw); %size of the referance picture
    
    %Detect features
    points488_raw = detectHarrisFeatures(I488, 'FilterSize', f);
    points488 = sortrows(points488_raw.Location, [-2 1]);
    
    points647_raw = detectHarrisFeatures(I647, 'FilterSize', f);
    points647 = sortrows(points647_raw.Location, [-2 1]);
    
    %     figure(1)
    %     tiledlayout(2,2)
    %     nexttile; imagesc(Grid_488_raw); title('Raw 488')
    %     nexttile; imshow(imadjust(I488)); hold on; plot(points488_raw); title('Detection 488'); hold off;
    %     nexttile; imagesc(Grid_647_reg); title('Raw 647')
    %     nexttile; imshow(imadjust(I488)); hold on; plot(points488_raw); title('Detection 647'); hold off;
    
    sorted_488 = zeros(length(points488), 2);
    sorted_647 = zeros(length(points647), 2);
    
    %Accept detection
    %     m=input('Do you want to continue, Y/N:','s');
    %     if m=='N'
    %         close all
    %         return
    %
    %     elseif m=='Y'
    %Create registration mask
    %but correct for terrible matching of
    %detection grid
    %if you delet numbers bigger from around xzero then you automatically
    %elimnaets unaligned points :) done
    for gg = 1:length(points488)
        if points488(gg,2) - points488(gg+1,2) > 8
            break
        end
    end
    
    for ff = 0:(length(points488)/gg)-1
        sorted_488(1+(gg*ff):gg+(gg*ff),:) = sortrows(points488(1+(gg*ff):gg+(gg*ff), :), -1);
        sorted_647(1+(gg*ff):gg+(gg*ff),:) = sortrows(points647(1+(gg*ff):gg+(gg*ff), :), -1);
    end
    
    n = length(sorted_488); % number of grid holes to be used for registration (x,y coordinates)
    tform = fitgeotrans(sorted_647, sorted_488, 'lwm', n);
    %     end
    close all
    
    ContentInFold = dir(yourpath);
    
    
    
    for i = 1:length(ContentInFold)
        if strfind(ContentInFold(i).name, 'STAR') >= 1 & what_a_day_to_code == 0
            T488_cor_path = [yourpath, '/', 'Data_analysis', '/', ContentInFold(i).name(1:end-4), '/', ContentInFold(i).name(1:end-4), '_488_Cor.tif'];
            T647_cor_path = [yourpath, '/', 'Data_analysis', '/', ContentInFold(i).name(1:end-4), '/', ContentInFold(i).name(1:end-4), '_647_Cor.tif'];
            r_488 = bfGetReader(T488_cor_path);
            I_488 = bfGetPlane(r_488, 1);
            r_647 = bfGetReader(T647_cor_path);
            I_647 = bfGetPlane(r_647, 1);
            I_647_raw = I_647;
            I_647 = imwarp(I_647, tform, 'OutputView', imref2d(I));
            
            if zz == 0
                
                zz = 1;
                figure(1);
                tiledlayout(2,3)
                nexttile; imagesc(Grid_488_raw); title('Raw 488'); axis equal;
                nexttile; imshow(imadjust(I488)); hold on; plot(points488_raw); title('Detection 488'); hold off; axis equal;
                nexttile; imshowpair(I_488, I_647_raw, 'ColorChannels', 'green-magenta'); title('RAW overlay'); axis equal;
                nexttile; imagesc(Grid_647_reg); title('Raw 647'); axis equal;
                nexttile; imshow(imadjust(I488)); hold on; plot(points488_raw); title('Detection 647'); hold off; axis equal;
                nexttile; imshowpair(I_488, I_647, 'ColorChannels', 'green-magenta'); title('Registered overlay'); axis equal;
                
                m=input('Do you want to continue, Y/N:','s');
                
                if m=='N'
                    close all %%% this is where you finished
                    openvar('points488')
                    openvar('points647')
                    fprintf('Fix the detection points manually')
                    n = length(points488); % number of grid holes to be used for registration (x,y coordinates)
%                     save([yourpath, '/Corrections/points488_fixed.mat'], 'points488')
%                     save([yourpath, '/Corrections/points647_fixed.mat'], 'points647')
                    tform = fitgeotrans(points647, points488, 'lwm', n);
                    I_647 = imwarp(I_647_raw, tform, 'OutputView', imref2d(I));
                    imshowpair(I_488, I_647, 'ColorChannels', 'green-magenta'); title('NEW Registered overlay'); axis equal;
                    
                    m=input('Do you want to continue, Y/N:','s');
                    if m=='N'
                        assignin('base','I_488_2bTRANS', I_488)
                        assignin('base','I_647_2bTRANS', I_647)
                        OS_IMG_TRANSLATION
                        %open the calibration appp then extract X and Y
                        %and add it to the points 647 (translation)
                    
                    choice = menu('Press OK after aligment','OK');
                    
                    X_TRANS = evalin('base','X_TRANS');
                    Y_TRANS = evalin('base','Y_TRANS');
                    
                    if isequal(X_TRANS, [])
                        X_TRANS = 0;
                    end
                    
                    if isequal(Y_TRANS, [])
                        Y_TRANS = 0;
                    end
                    
                    points647(:, 1) = points647(:, 1) -  X_TRANS;
                    points647(:, 2) = points647(:, 2) -  Y_TRANS;
                    
                    tform = fitgeotrans(points647, points488, 'lwm', n);
                    I_647 = imwarp(I_647_raw, tform, 'OutputView', imref2d(I));
                    imshowpair(I_488, I_647, 'ColorChannels', 'green-magenta'); title('NEW Registered overlay'); axis equal;
                    
                    m=input('Do you want to continue, Y/N:','s');
                    if m=='N'
                        fprintf('Registration mask generation failed')
                        return 
                    end
                    
                    save([yourpath, '/Corrections/points488_fixed.mat'], 'points488')
                     save([yourpath, '/Corrections/points647_fixed.mat'], 'points647')
                    
                    elseif m=='Y'
                     save([yourpath, '/Corrections/points488_fixed.mat'], 'points488')
                     save([yourpath, '/Corrections/points647_fixed.mat'], 'points647')
                    
                    end
                    
                    
                elseif m=='Y'
                    close all
                end
            end
            what_a_day_to_code = 1;
        end
    end
else %after points fixetaion just load inthe fixed points
    ContentInFold = dir(yourpath);
    I = size(Grid_488_raw);
    load([yourpath, '/Corrections/points488_fixed.mat'])
    load([yourpath, '/Corrections/points647_fixed.mat'])
    n = length(points488);
    tform = fitgeotrans(points647, points488, 'lwm', n);
end

for i = 1:length(ContentInFold)
    if strfind(ContentInFold(i).name, 'STAR') >= 1
        
        T647_cor_path = [yourpath, '/', 'Data_analysis', '/', ContentInFold(i).name(1:end-4), '/', ContentInFold(i).name(1:end-4), '_647_Cor.tif'];
        T647_Cor = bfopen(T647_cor_path);
        T647_Cor_Reg = cell(length(T647_Cor{1,1}),1);
        
        for ii = 1:length(T647_Cor{1,1})
            T647_Cor_Reg{ii,1} = zeros(size(T647_Cor{1,1}{1,1}));
        end
        
        for k = 1:length(T647_Cor_Reg)
            T647_Cor_Reg{k, 1} = imwarp(T647_Cor{1,1}{k,1}, tform, 'OutputView', imref2d(I));
        end
        
        
        fn647 = [yourpath, '/', 'Data_analysis', '/', ContentInFold(i).name(1:end-4), '/', ContentInFold(i).name(1:end-4), '_647_Cor_Reg.tif'];
        cell_mat2tiff(fn647, T647_Cor_Reg);
        T647_Cor_Cor = [];
        T647_Cor_Reg = [];
    end
end
fprintf('<3 Registration completed <3 \n');
end