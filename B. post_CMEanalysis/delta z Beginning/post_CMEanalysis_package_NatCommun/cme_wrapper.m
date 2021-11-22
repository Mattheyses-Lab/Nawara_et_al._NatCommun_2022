%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b / it is a wrap that asks once runned to first slect
%%% folder where data from experiment(s) is located. Do not chose the
%%% folder that contains all the cells but the location of that folder

function cme_wrapper

selpath = uigetdir; %automatic path selection
dz_beginning(selpath); %dz calculation and the core of the wraper

%final means for different bedning models and liftimecohorts structre
structure = evalin('base','structure');
name2save = [selpath, '/', 'Time_vs_model.csv'];
writecell(name2save, 'structure')
clear

end