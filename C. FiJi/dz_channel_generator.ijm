//This work is licensed under the Creative Commons Attribution 4.0
//International License. To view a copy of this license, visit
//http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
//Commons, PO Box 1866, Mountain View, CA 94042, USA.

// make sure to adjust sigma (line 21) and multipling value (line 47)
cell_num = "003"

experiment = "OS_CLC-STAR."
dir = "C:/Users/tnawara/Desktop/Nawara - Nat Commun/5. Test data sets/C. FiJi/"
cell = experiment + cell_num;
Cell_488 = cell + "_488_Cor.tif";
Cell_647 = cell + "_647_Cor_Reg.tif";
dir2save = dir + cell + "/";
dir2open_488 = dir2save + Cell_488;
dir2open_647 = dir2save + Cell_647;
open(dir2open_488);
open(dir2open_647);

selectWindow(Cell_488);
run("Gaussian Blur...", "sigma=1.03 stack");
dir_name_blur = dir2save + cell + "_488_Cor_Blur.tif"
saveAs("Tiff", dir_name_blur);
run("Z Project...", "stop=10 projection=[Average Intensity]");
name_blur = cell + "_488_Cor_Blur.tif";
name_avg_blur = "AVG_"+ cell + "_488_Cor_Blur.tif";
imageCalculator("Divide create 32-bit stack", name_blur, name_avg_blur);
results_488 = "Result of " + name_blur;

selectWindow(Cell_647);
run("Z Project...", "stop=10 projection=[Average Intensity]");
name_avg_647 =  "AVG_"+ Cell_647;
imageCalculator("Divide create 32-bit stack", Cell_647, name_avg_647);
results_647 = "Result of " + Cell_647;

imageCalculator("Divide create 32-bit stack", results_647, results_488);
name_ratio_647_488 = "Result of Result of " + Cell_647;

selectWindow(name_ratio_647_488);
dir_name_ratio = dir2save + "Ratio_" + cell;
name_ratio = "Ratio_" + cell + ".tif";

saveAs("Tiff", dir_name_ratio);

selectWindow(name_ratio);
run("Log", "stack");
run("Multiply...", "value=404.000 stack");
dir_name_dz = dir2save + "dZ_" + cell;
saveAs("Tiff", dir_name_dz);
run("Close All");