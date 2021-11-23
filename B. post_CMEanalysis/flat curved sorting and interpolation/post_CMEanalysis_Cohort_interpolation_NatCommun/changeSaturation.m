%This work is licensed under the Creative Commons Attribution 4.0
%International License. To view a copy of this license, visit
%http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
%Commons, PO Box 1866, Mountain View, CA 94042, USA.

function [r, g, b] = changeSaturation(R,G,B,change)
Pr  = 0.299;
Pg  = 0.587;
Pb  = 0.114;
P=sqrt(R*R*Pr+G*G*Pg+B*B*Pb);
r=P+(R-P)*change;
b=P+(B-P)*change;
g=P+(G-P)*change;

end