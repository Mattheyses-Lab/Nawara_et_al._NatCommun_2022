function image_anotation_EPI(T488, T647, E488, dz)

frame_rate = 1.25;
% T488 = bfopen(T488);
% T647 = bfopen(T647);
E488 = bfopen(E488);
% dz = bfopen(dz);

position = [1 1];
time = (0:length(E488{1, 1})-1)*frame_rate;
[~, Y,~] = size(E488{1, 1}{1, 1});

%     for ii = 1:length(T488{1, 1})
%         T488{1, 1}{ii, 1} = insertText(T488{1, 1}{ii, 1}, position, 'TIRF 488','FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
%         imwrite(T488{1, 1}{ii, 1}, 'Composit_T488_annotated.tif',... %name of the to be saved file
%         'writemode','append','Compression','none');
%     end 
%     
%     for ii = 1:length(T647{1, 1})
%         T647{1, 1}{ii, 1} = insertText(T647{1, 1}{ii, 1}, position, 'TIRF 647','FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
%         imwrite(T647{1, 1}{ii, 1}, 'Composit_T647_annotated.tif',... %name of the to be saved file
%         'writemode','append','Compression','none');
%     end  
    
    for ii = 1:length(E488{1, 1})
        E488{1, 1}{ii, 1} = insertText(E488{1, 1}{ii, 1}, position, 'EPI 488','FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
        E488{1, 1}{ii, 1} = insertText(E488{1, 1}{ii, 1}, [Y-170 1], sprintf('%0.5g s',time(ii)),'FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
        imwrite(E488{1, 1}{ii, 1}, 'Composit_E488_annotated_new.tif',... %name of the to be saved file
        'writemode','append','Compression','none');
    end
    
%     for ii = 1:length(dz{1, 1})
%         dz{1, 1}{ii, 1} = insertText(dz{1, 1}{ii, 1}, position, 'Curvature', 'FontSize',30, 'TextColor', 'white', 'BoxOpacity', 0);
%         imwrite(dz{1, 1}{ii, 1}, 'Composit_dz_annotated.tif',... %name of the to be saved file
%         'writemode','append','Compression','none');
%     end 
end