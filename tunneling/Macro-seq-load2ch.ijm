folder="/Users/liang/Downloads/222222222222222/E-Syt3/";
folder+="TG 200nM 20s/20160604_150X_Hela-pML2-C0-ESyt3_200nMTG 20s_0.1um_cell2_1";

run("Image Sequence...", "open=["+folder+"/Pos0] file=GFP sort");
//run("Enhance Contrast...", "saturated=0.4 process_all"); // later if need to quantify things
rename("488");
run("Duplicate...", "duplicate");
//run("Enhance Contrast...", "saturated=0.4 process_all");

run("Image Sequence...", "open=["+folder+"/Pos0] file=561 sort");
//run("Enhance Contrast...", "saturated=0.4 process_all");
rename("561");
run("Duplicate...", "duplicate");

run("Merge Channels...", "c1=561-1 c2=488-1");

selectWindow("RGB");
for (i=0; i<nSlices; i++) {
  wait(20);
  run("Next Slice [>]");
}
//selectWindow("561"); // default: RGB
run("Set Measurements...", "area mean standard bounding redirect=None decimal=1");
run("Set Scale...", "distance=1 known=0.0806 unit=um");