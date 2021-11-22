bead_num = "004"

dir = "E:/STAR data 2/Beads splitted/"
dir2save = "E:/STAR data 2/Beads splitted/OS_uBeads" + "." + bead_num 
dir_EPI = "E:/STAR data 2/Beads splitted/OS_uBeads" + "." + bead_num + ".nd2"
dir_TIRF = "E:/STAR data 2/Beads splitted/OS_uBeads" + "_TIRF"  + "." + bead_num + ".nd2"
File.makeDirectory(dir2save);

open(dir_EPI);
run("Split Channels");
selectWindow("C1-E:/STAR data 2/Beads splitted/OS_uBeads." + bead_num + ".nd2");
run("Cairn Image Splitter");
waitForUser("1.Click Open Last Aligment in image spplitter 2.wait until its done 3. pres OK")

EPI_488 = "C1-E:/STAR data 2/Beads splitted/OS_uBeads." + bead_num + " Channel 1.nd2"
selectWindow(EPI_488);
saveAs("Tiff", dir2save + "/" + bead_num + "_EPI_488.tif");

selectWindow("C2-E:/STAR data 2/Beads splitted/OS_uBeads." + bead_num + ".nd2");
run("Cairn Image Splitter");
waitForUser("1.Click Open Last Aligment in image spplitter 2.wait until its done 3. pres OK")

EPI_647 = "C2-E:/STAR data 2/Beads splitted/OS_uBeads." + bead_num + " Channel 2.nd2"
selectWindow(EPI_647);
saveAs("Tiff", dir2save + "/" + bead_num + "_EPI_647.tif");
run("Close All");

open(dir_TIRF);
run("Cairn Image Splitter");
waitForUser("1.Click Open Last Aligment in image spplitter 2.wait until its done 3. pres OK")

TIRF_488 = "E:/STAR data 2/Beads splitted/OS_uBeads_TIRF." + bead_num + " Channel 1.nd2"
selectWindow(TIRF_488);
saveAs("Tiff", dir2save + "/" + bead_num + "_TIRF_488.tif");

TIRF_647 = "E:/STAR data 2/Beads splitted/OS_uBeads_TIRF." + bead_num + " Channel 2.nd2"
selectWindow(TIRF_647);
saveAs("Tiff", dir2save + "/" + bead_num + "_TIRF_647.tif");
run("Close All");