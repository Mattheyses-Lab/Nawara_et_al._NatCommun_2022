%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

%How to run:
%Change final file name at lline 60
%image_overlay('488T_8bit.tif', '488T_Crop_8bit.tif', 2, 2, 100, 118, 130, 130, 488)
%image_overlay('647T_8bit.tif', '647T_Crop_8bit.tif', 2, 2, 100, 118, 130, 130, 647)
%image_overlay('DZ_8bit.tif', 'DZ_Crop_8bit.tif', 2, 2, 100, 118, 130, 130, true)


function image_overlay(big, small, resize, frame, X_corner, Y_corner, width, height, dz)

big = bfopen(big);
small = bfopen(small);
y = X_corner;
x = Y_corner;

%make a mask using 647 channel
if dz == true
    load('mask.mat')
    [xx, yy] = size(big{1, 1}{1, 1});
    
elseif dz == 647
    [msk,~] = OtsuThreshold(big{1, 1}{1, 1});
    msk_dil = imdilate(msk,ones(18,18));
    mask = imerode(msk_dil,ones(20,20));
    save('mask.mat', 'mask')
elseif dz == 488
    fprintf('make a mask using 647 channel');
end

for ii = 1:length(small{1, 1})
    small{1, 1}{ii, 1}  = imresize(small{1, 1}{ii, 1}, resize);
    [X, Y] = size(small{1, 1}{ii, 1});
    small{1, 1}{ii, 1}(1:frame, 1:end) = 255;
    small{1, 1}{ii, 1}(end-frame:end, 1:end) = 255;
    small{1, 1}{ii, 1}(1:end, 1:frame) = 255;
    small{1, 1}{ii, 1}(1:end, end-frame:end) = 255;
    
    big{1, 1}{ii, 1}(x:x+round(frame/2), y:y+width) = 255;
    big{1, 1}{ii, 1}(x+height:x+height+round(frame/2), y:y+width) = 255;
    big{1, 1}{ii, 1}(x:x+width, y:y+round(frame/2)) = 255;
    big{1, 1}{ii, 1}(x:x+width, y+width:y+width+round(frame/2)) = 255;
    
    if dz == true
        for col = 1:yy
            for row = 1:xx
                if mask(row, col) == 0
                    big{1, 1}{ii, 1}(row, col) = 0;
                end
            end
        end
    end
    
    big{1, 1}{ii, 1}(end-(X-1):end, 1:Y) = 0;
    big{1, 1}{ii, 1}(end-(X-1):end, 1:Y) = small{1, 1}{ii, 1};
    
    imwrite(big{1, 1}{ii, 1}, 'Composit_488T_marked.tif',... %name of the to be saved file
        'writemode','append','Compression','none');
end
end

function [msk,thrsh] = OtsuThreshold(im)
hst = imhist(im);
res = otsuthresh(hst);
thrsh = res*255;
msk = im>thrsh;
end
