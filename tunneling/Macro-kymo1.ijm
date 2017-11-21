run("Colors...", "foreground=white background=black selection=yellow");
run("Images to Stack", "method=[Copy (center)] name=kymo title=Kymo use");
run("8-bit");
run("Make Montage...", "columns="+nSlices+" rows=1 scale=1 first=1 last="+nSlices+" increment=1 border=0 font=12");

