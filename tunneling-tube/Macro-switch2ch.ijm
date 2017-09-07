getDimensions(width, height, channels, slices, frames);
makeRectangle(0, 0, width/3, height);

run("Duplicate...", "title=2ch");
run("Split Channels");
run("Merge Channels...", "c1=[2ch (red)] c2=[2ch (green)] c3=[2ch (blue)] keep");

combine=""; // combine
run("Combine...", "stack2=[2ch (red)] stack1=[2ch (green)] "+combine);
run("RGB Color");
selectWindow("2ch (blue)");
close();
run("Combine...", "stack1=RGB stack2=[Combined Stacks] "+combine);

//run("Set Scale...", "distance=1 known=0.0946 unit=um");
//run("Scale Bar...", "width=5 height=4 font=14 color=White background=None location=[Lower Right]");