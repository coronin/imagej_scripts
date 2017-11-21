range="11-47";

selectWindow("Pos0 #1");
run("Duplicate...", "title=red duplicate range="+range);
selectWindow("red");
run("Enhance Contrast...", "saturated=0.3 normalize process_all");
run("8-bit");

selectWindow("Pos0 #2");
run("Duplicate...", "title=green duplicate range="+range);
selectWindow("green");
run("Enhance Contrast...", "saturated=1 normalize process_all use");
run("8-bit");

run("Merge Channels...", "c1=red c2=green");
selectWindow("RGB");