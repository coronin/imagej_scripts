dir="LDLR/1ng ml cholesterol 1min/20160605_150X_Hela-LDLR-mRedf_1ng ml cholesterol 1min_0.1um_cell1_1";

run("Image Sequence...", "open=[/Users/liang/Downloads/222222222222222/"+dir+"/Pos0] file=561 sort");
run("Enhance Contrast...", "saturated=0.4 process_all");
rename("red");
run("8-bit");

run("Image Sequence...", "open=[/Users/liang/Downloads/222222222222222/"+dir+"/Pos0] file=GFP sort");
run("Enhance Contrast...", "saturated=0.4 process_all use");
rename("green");
run("8-bit");

run("Merge Channels...", "c1=red c2=green "); // keep
