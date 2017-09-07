file="xx";
stks="1,15,28,42,47,48,49,52";
cnts="8";

//run("Save", "save=/Users/liang/Desktop/"+file+"_crop-RGB.tif");
//run("Enhance Contrast...", "saturated=0.1 process_all use");

run("Time Stamper", "starting=0 interval=0.5 x=2 y=14 font=12 decimal=1 anti-aliased or=s");
run("Make Substack...", "  slices=["+stks+"]");
run("Save", "save=[/Users/liang/Desktop/"+file+"_crop-substack("+stks+")]");

//run("Make Montage...", "columns="+cnts+" rows=1 scale=1 border=1");
run("Make Montage...", "rows="+cnts+" columns=1 scale=1 border=1");
