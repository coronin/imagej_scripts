selectWindow("1");

run("Set Scale...", "distance=1 known=0.0946 unit=um");
run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[Upper Right]");

run("Rotate 90 Degrees Right");

run("Set Scale...", "distance=1 known=0.5 pixel=1 unit=s");
run("Scale Bar...", "width=60 height=4 font=14 color=White background=None location=[Upper Right] hide");

run("Rotate 90 Degrees Left");