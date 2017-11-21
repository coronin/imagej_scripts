a="35";
b="47";

selectWindow("img_000000000_GFP_0"+a+".tif");
run("Show Info...");

run("Images to Stack", "name=Stack title=[] use");
run("Enhance Contrast...", "saturated=0.3 process_all");
run("8-bit");
run("Stack to Images");
run("Merge Channels...", "c1=img_000000000_mCherry_0"+a+" c2=img_000000000_GFP_0"+a);
rename("RGB"+a);
run("Merge Channels...", "c1=img_000000000_mCherry_0"+b+" c2=img_000000000_GFP_0"+b);
rename("RGB"+b);

selectWindow("RGB"+a);
run("Duplicate...", "title=RGB");
run("Split Channels");
selectWindow("RGB (blue)");
close();
selectWindow("RGB"+a);
run("Set Scale...", "distance=1 known=0.0946 unit=um");
run("Scale Bar...", "width=10 height=4 font=24 color=White background=None location=[Upper Left]");
selectWindow("RGB (red)");
run("RGB Color");
selectWindow("RGB (green)");
run("RGB Color");
run("Combine...", "stack1=RGB"+a+" stack2=[RGB (red)]");
run("Combine...", "stack1=[Combined Stacks] stack2=[RGB (green)]");
selectWindow("Combined Stacks");
rename("done"+a);

selectWindow("RGB"+b);
run("Duplicate...", "title=RGB");
run("Split Channels");
selectWindow("RGB (blue)");
close();
selectWindow("RGB"+b);
run("Set Scale...", "distance=1 known=0.0946 unit=um");
run("Scale Bar...", "width=10 height=4 font=24 color=White background=None location=[Upper Left]");
selectWindow("RGB (red)");
run("RGB Color");
selectWindow("RGB (green)");
run("RGB Color");
run("Combine...", "stack1=RGB"+b+" stack2=[RGB (red)]");
run("Combine...", "stack1=[Combined Stacks] stack2=[RGB (green)]");
selectWindow("Combined Stacks");
rename("done"+b);