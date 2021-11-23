%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2018a 
%%% yourpath is a path to folder that contains data from experimental day
%%% Example: yourpath = '/data/user/tnawara/Data/Data analysis/AA_First
%%% paper/Revisions/siRNA/Exp1';
%%% use after running CMEanalysis it will automatically save deteced tracks and cell
%%% masks needed for further analysis of curvature formation dynamics into
%%% a folder called Export_tracks in the same path that provided

%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.


function CME_extractor(yourpath)

mkdir([yourpath, '/', 'Export_tracks']); %Creating new folder fro export

    ContentInFold = dir(yourpath);
    for i = 3:length(ContentInFold)-1
        path_1 = [ContentInFold(i).folder, '/', ContentInFold(i).name];
        ContentInSubFold = dir(path_1);
        
        %localizing files
        for ii = 3:length(ContentInSubFold)
            path2tracks = [ContentInSubFold(ii).folder, '/', 'Ch1/Tracking/ProcessedTracks.mat'];
            path2mask = [ContentInSubFold(ii).folder, '/', 'Ch1/Detection/cellmask.tif'];
            
            NewNameTracks = [yourpath, '/', 'Export_tracks', '/', ContentInFold(i).name, '_Tracks.mat'];
            NewNameMask = [yourpath, '/', 'Export_tracks', '/', ContentInFold(i).name, '_Mask.tif'];
            
            %coping files to new destination
            copyfile(path2tracks, NewNameTracks);
            copyfile(path2mask, NewNameMask);
        end            
    end
end

