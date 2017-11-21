selectWindow("Pos0 #2");
run("Duplicate...", "title=tube duplicate range=1-30"); //  range=81-300
run("Enhance Contrast...", "saturated=0.4 process_all");
selectWindow("Pos0 #1");
run("Duplicate...", "title=11 duplicate range=1-30");
run("Enhance Contrast...", "saturated=0.4 process_all");

run("Combine...", "stack1=11 stack2=tube combine");
run("Set Scale...", "distance=1 known=0.0946 unit=um");
run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[Lower Left] label");

run("Colors...", "foreground=white background=black selection=yellow");
run("Time Stamper", "starting=0 interval=0.5 x=4 y=18 font=14 decimal=1 anti-aliased or=sec");

run("8-bit");