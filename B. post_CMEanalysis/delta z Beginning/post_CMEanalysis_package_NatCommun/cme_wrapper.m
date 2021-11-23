%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b / it is a wrap that asks once runned to first slect
%%% folder where data from experiment(s) is located. Do not chose the
%%% folder that contains all the cells but the location of that folder

%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function cme_wrapper

selpath = uigetdir; %automatic path selection
dz_beginning(selpath); %dz calculation and the core of the wraper

%final means for different bedning models and liftimecohorts structre
structure = evalin('base','structure');
name2save = [selpath, '/', 'Time_vs_model.csv'];
writecell(name2save, 'structure')
clear

end