%%% Function created by Nawara T. (Mattheyses lab - 10/26/2021) compatible
%%% with MATLAB R2020b/ a = data_total
%%% it will print representative tracks for threee different bending models

%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function dz_representative(a)
close all
buf = 15; %buffer after beginignif clc
frame_rate = 0.3;
x_in_s = [(-buf+1):1:buf]*frame_rate;

%[oldFileNames,~] = uigetfile('*.mat','Select the mat-files', 'MultiSelect','off');
%load(oldFileNames);

es = 1;
ts = 1;
as = 1;

for i = 1:size(a,2)      
   if  a(i).dzvsCLC_s <= -1.5 & a(i).dzvsCLC_s >= -2.5 %events with dz vs CLC < -3s
        x1 = a(i).A_withSbuf(1,1:15+buf); %488
        x2 = a(i).A_withSbuf(2,1:15+buf); %647
        x3 = a(i).A_withSbuf(3,1:15+buf); %dz
        if es == 1
            e1 = x1; e2 = x2; e3 = x3;
            es = 2;  
        elseif es > 1
        e1 = [e1; x1]; e2 = [e2; x2]; e3 = [e3; x3];
        end
        
   elseif a(i).dzvsCLC_s == 0 %events with dz vs CLC == 0s
        x1 = a(i).A_withSbuf(1,1:15+buf); %488
        x2 = a(i).A_withSbuf(2,1:15+buf); %647
        x3 = a(i).A_withSbuf(3,1:15+buf); %dz
        if ts == 1
            t1 = x1; t2 = x2; t3 = x3;
            ts = 2;  
        elseif ts > 1
        t1 = [t1; x1]; t2 = [t2; x2]; t3 = [t3; x3];
        end
        
    elseif a(i).dzvsCLC_s >= 1 & a(i).dzvsCLC_s <= 2  %events with dz vs CLC < 4s %% > 5s
        x1 = a(i).A_withSbuf(1,1:15+buf); %488
        x2 = a(i).A_withSbuf(2,1:15+buf); %647
        x3 = a(i).A_withSbuf(3,1:15+buf); %dz
        if as == 1
            a1 = x1; a2 = x2; a3 = x3;
            as = 2;  
        elseif es > 1
        a1 = [a1; x1]; a2 = [a2; x2]; a3 = [a3; x3];
        end
    
    end
end
%Nucleation
e1_mean = mean(e1); e2_mean = mean(e2); e3_mean = mean(e3);
e1_SEM = std(e1)/sqrt(length(e1)); e2_SEM = std(e2)/sqrt(length(e2)); e3_SEM = std(e3)/sqrt(length(e3));
figure(1)
subplot(3,1,1); errorbar(x_in_s, e1_mean, e1_SEM,'-c'); hold on;...
    title(sprintf('Nucleation, n = %i', size(e1,1)))
    ylabel('F.I. 488 [a.u.]');
    xline(0,'r--','LineWidth',1)
    axis([-5 5 0 500])
subplot(3,1,2); errorbar(x_in_s, e2_mean, e2_SEM,'-m');
    ylabel('F.I. 647 [a.u.]');
    xline(0,'r--','LineWidth',1)
    axis([-5 5 0 250])
subplot(3,1,3); errorbar(x_in_s, e3_mean, e3_SEM,'Color', '#FFA500');
    ylabel('dz [nm]');
    xlabel('Time [s]');
    xline(-2,'r--','LineWidth',1)
    axis([-5 5 -50 200])

%CCM
t1_mean = mean(t1); t2_mean = mean(t2); t3_mean = mean(t3);
t1_SEM = std(t1)/sqrt(length(t1)); t2_SEM = std(t2)/sqrt(length(t2)); t3_SEM = std(t3)/sqrt(length(t3));
figure(2)
subplot(3,1,1); errorbar(x_in_s, t1_mean, t1_SEM,'-c'); hold on;...
    title(sprintf('CCM, n = %i', size(t1,1)))
    ylabel('F.I. 488 [a.u.]');
    xline(0,'r--','LineWidth',1)
    axis([-5 5 0 500])
subplot(3,1,2); errorbar(x_in_s, t2_mean, t2_SEM,'-m');
    ylabel('F.I. 647 [a.u.]');
    xline(0,'r--','LineWidth',1)
    axis([-5 5 0 250])
subplot(3,1,3); errorbar(x_in_s, t3_mean, t3_SEM,'Color', '#FFA500');
    ylabel('dz [nm]');
    xlabel('Time [s]');
    xline(0,'r--','LineWidth',1)
    axis([-5 5 -50 200])

%FTC
a1_mean = mean(a1); a2_mean = mean(a2); a3_mean = mean(a3);
a1_SEM = std(a1)/sqrt(length(a1)); a2_SEM = std(a2)/sqrt(length(a2)); a3_SEM = std(a3)/sqrt(length(a3));
figure(3)
subplot(3,1,1); errorbar(x_in_s, a1_mean, a1_SEM,'-c'); hold on;...
    title(sprintf('FTC, n = %i', size(a1,1)))
    ylabel('F.I. 488 [a.u.]');
    xline(0,'r--','LineWidth',1)
    axis([-5 5 0 500])
subplot(3,1,2); errorbar(x_in_s, a2_mean, a2_SEM,'-m');
    ylabel('F.I. 647 [a.u.]');
    xline(0,'r--','LineWidth',1)
    axis([-5 5 0 250])
subplot(3,1,3); errorbar(x_in_s, a3_mean, a3_SEM, 'Color', '#FFA500');
    ylabel('dz [nm]');
    xlabel('Time [s]');
    xline(1.5,'r--','LineWidth',1)
    axis([-5 5 -50 200])

% csvwrite('e1.csv',e1); csvwrite('e2.csv',e2); csvwrite('e3.csv',e3);
% csvwrite('t1.csv',t1); csvwrite('t2.csv',t2); csvwrite('t3.csv',t3);
% csvwrite('a1.csv',a1); csvwrite('a2.csv',a2); csvwrite('a3.csv',a3);
end