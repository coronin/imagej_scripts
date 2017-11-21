w=262;
h=237;

run("Duplicate...", "duplicate");
rename("it");

selectWindow("it");
makeRectangle(0, 0, w, h);
run("Duplicate...", "duplicate");
//run("Enhance Contrast...", "saturated=0.4 process_all");
rename("green");

selectWindow("it");
makeRectangle(w, 0, w, h);
run("Duplicate...", "duplicate");
run("Enhance Contrast...", "saturated=0.4 process_all");
rename("red");

selectWindow("it");
close();
//run("8-bit");
