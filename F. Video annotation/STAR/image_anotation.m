function image_anotation(T488, T647, dz)

frame_rate = 0.3;
T488 = bfopen(T488);
T647 = bfopen(T647);
dz = bfopen(dz);

position = [1 1];
time = (0:length(T488{1, 1})-1)*frame_rate;
[~, Y,~] = size(T488{1, 1}{1, 1});

    for ii = 1:length(T488{1, 1})
        T488{1, 1}{ii, 1} = insertText(T488{1, 1}{ii, 1}, position, 'TIRF 488 & TIRF 647','FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
        T488{1, 1}{ii, 1} = insertText(T488{1, 1}{ii, 1}, [Y-170 1], sprintf('%0.5g s',time(ii)),'FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
        imwrite(T488{1, 1}{ii, 1}, 'Composit_T488_annotated.tif',... %name of the to be saved file
        'writemode','append','Compression','none');
    end 
    
    for ii = 1:length(T647{1, 1})
        T647{1, 1}{ii, 1} = insertText(T647{1, 1}{ii, 1}, position, 'TIRF 488 & TIRF 647','FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
        imwrite(T647{1, 1}{ii, 1}, 'Composit_T647_annotated.tif',... %name of the to be saved file
        'writemode','append','Compression','none');
    end  
    
    for ii = 1:length(dz{1, 1})
        dz{1, 1}{ii, 1} = insertText(dz{1, 1}{ii, 1}, position, 'Curvature', 'FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
        imwrite(dz{1, 1}{ii, 1}, 'Composit_dz_annotated.tif',... %name of the to be saved file
        'writemode','append','Compression','none');
    end 
end