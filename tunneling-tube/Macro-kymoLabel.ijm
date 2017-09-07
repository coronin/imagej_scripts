run("Set Scale...", "distance=1 known=0.0806 unit=um"); // 0.0946
run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[Lower Right] hide"); // label hide

run("Rotate 90 Degrees Left");
run("Set Scale...", "distance=60 known=30 pixel=1 unit=s");
run("Scale Bar...", "width=30 height=2 font=14 color=White background=None location=[Lower Right] hide");
run("Rotate 90 Degrees Right");
