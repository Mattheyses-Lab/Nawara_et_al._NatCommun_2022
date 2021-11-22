function [GAP_matrix] = GAP_analysis(data)


%GAP_matrix = cell(14,2);
% for zz = 0:13
%     GAP_matrix{zz+1,1} = num2str(zz);
% end

GAP_matrix = [];

for ii = 1:length(data)
    if isempty(data(ii).GAP_frames)
        GAP_matrix = [GAP_matrix; 0];
        
    elseif size(data(ii).GAP_frames, 2) == 1
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        
    elseif size(data(ii).GAP_frames, 2) == 2
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        
    elseif size(data(ii).GAP_frames, 2) == 3
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        
    elseif size(data(ii).GAP_frames, 2) == 4
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 4})];
        
    elseif size(data(ii).GAP_frames, 2) == 5
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 4})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 5})];
        
    elseif size(data(ii).GAP_frames, 2) == 6
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 4})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 5})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 6})];
        
    elseif size(data(ii).GAP_frames, 2) == 7
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 4})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 5})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 6})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 7})];
        
    elseif size(data(ii).GAP_frames, 2) == 8
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 4})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 5})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 6})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 7})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 8})];
        
    elseif size(data(ii).GAP_frames, 2) == 9
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 4})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 5})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 6})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 7})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 8})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 9})];
       
        
        
    elseif size(data(ii).GAP_frames, 2) == 10
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 1})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 2})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 3})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 4})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 5})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 6})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 7})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 8})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 9})];
        GAP_matrix = [GAP_matrix; length(data(ii).GAP_frames{1, 10})];
           
        
    end
end

end

% MAX_length = 0
% for ii = 1:length(data_total)
%     if size(data_total(ii).GAP_frames, 2) > MAX_length
%         MAX_length = size(data_total(ii).GAP_frames, 2);
%     end
% end
% count = 1
% for ii = 1:length(data_total)
%     if ~isempty(data_total(ii).dzvsCLC_s);
%     data(count) = data_total(ii);
%     count = count + 1;
%     end
% end


