%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b / it is a wrap that asks once runned to first slect
%%% folder where data from experiment(s) is located. Do not chose the
%%% folder that contains all the cells but the location of that folder
%%% hh = Cohort_interpolation_STAR(data, frame_rate[s], cohort_min_limit, cohort_max_limit, fig_number);
%%% hh is a color scaling factor that is determianed automatically

function cohort_wrapper


yourpath = uigetdir; %automatic path selection
CCV_vs_FCL_graph_generator(yourpath); %track sepration for dz poz and dz neg

close all %generation of interpolated cohorts
load([yourpath, '\data_total_dz_poz.mat']) %dz(+)
hh = Cohort_interpolation_STAR(dz_poz, 0.3, 80, 100, 1); %cohort 80-100
hh = Cohort_interpolation_STAR(dz_poz, 0.3, 60, 80, 1, hh); %cohort 60-80
hh = Cohort_interpolation_STAR(dz_poz, 0.3, 40, 60, 1, hh); %cohort 40-60
hh = Cohort_interpolation_STAR(dz_poz, 0.3, 20, 40, 1, hh); %cohort 20-40
Cohort_interpolation_STAR(dz_poz, 0.3, 10, 20, 1, hh); %cohort 10-20
load([yourpath, '\data_total_dz_neg']) %dz(-)
hh = Cohort_interpolation_STAR(dz_neg, 0.3, 80, 100, 2); %cohort 80-100
hh = Cohort_interpolation_STAR(dz_neg, 0.3, 60, 80, 2, hh); %cohort 60-80
hh = Cohort_interpolation_STAR(dz_neg, 0.3, 40, 60, 2, hh); %cohort 40-60
hh = Cohort_interpolation_STAR(dz_neg, 0.3, 20, 40, 2, hh);  %cohort 20-40
Cohort_interpolation_STAR(dz_neg, 0.3, 10, 20, 2, hh); %cohort 10-20

end