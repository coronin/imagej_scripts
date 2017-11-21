run("Stack Splitter", "number=2");
selectWindow("Pos0");
close();

//selectWindow("stk_0002_Pos0");
//close();

selectWindow("stk_0001_Pos0");
run("Enhance Contrast...", "saturated=0.3 normalize process_all");
