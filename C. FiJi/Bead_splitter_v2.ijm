//This work is licensed under the Creative Commons Attribution 4.0
//International License. To view a copy of this license, visit
//http://creativecommons.org/licenses/by/4.0/ or send a letter to Creative
//Commons, PO Box 1866, Mountain View, CA 94042, USA.

bead_num = "009"

dir = "E:/STAR data 2/11.23.20/"
dir2save = dir + "Data analysis/OS_uBeads" + "." + bead_num 
dir_EPI = dir + "OS_Bead_EPI" + "." + bead_num
dir_TIRF = dir + "OS_Bead_TIRF" + "." + bead_num
File.makeDirectory(dir2save);

open(dir_EPI + ".nd2");
run("Split Channels");
selectWindow("C1-" + dir_EPI + ".nd2");
run("Cairn Image Splitter");
waitForUser("1.Click Open Last Aligment in image spplitter 2.wait until its done 3. pres OK")

EPI_488 = "C1-" + dir_EPI + " Channel 1.nd2"
selectWindow(EPI_488);
saveAs("Tiff", dir2save + "/" + bead_num + "_EPI_488.tif");

selectWindow("C2-" + dir_EPI + ".nd2");
run("Cairn Image Splitter");
waitForUser("1.Click Open Last Aligment in image spplitter 2.wait until its done 3. pres OK")

EPI_647 = "C2-" + dir_EPI + " Channel 2.nd2"
selectWindow(EPI_647);
saveAs("Tiff", dir2save + "/" + bead_num + "_EPI_647.tif");
run("Close All");

open(dir_TIRF + ".nd2");
run("Split Channels");
selectWindow("C1-" + dir_TIRF + ".nd2");
run("Cairn Image Splitter");
waitForUser("1.Click Open Last Aligment in image spplitter 2.wait until its done 3. pres OK")

TIRF_488 = "C1-" + dir_TIRF + " Channel 1.nd2"
selectWindow(TIRF_488);
saveAs("Tiff", dir2save + "/" + bead_num + "_TIRF_488.tif");

selectWindow("C2-" + dir_TIRF + ".nd2");
run("Cairn Image Splitter");
waitForUser("1.Click Open Last Aligment in image spplitter 2.wait until its done 3. pres OK")

TIRF_647 = "C2-" + dir_TIRF + " Channel 2.nd2"
selectWindow(TIRF_647);
saveAs("Tiff", dir2save + "/" + bead_num + "_TIRF_647.tif");
run("Close All");