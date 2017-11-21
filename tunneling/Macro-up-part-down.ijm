w=509;
h=693;

rename("it");

selectWindow("it");
makeRectangle(0, 0, w, h/3);
run("Duplicate...", "duplicate");
rename("1");

selectWindow("it");
makeRectangle(0, h/3, w, h/3);
run("Duplicate...", "duplicate");
rename("2");

selectWindow("it");
makeRectangle(0, 2*h/3, w, h/3);
run("Duplicate...", "duplicate");
rename("3");

run("Combine...", "stack1=[3] stack2=[2] combine");
run("Combine...", "stack2=[1] stack1=[Combined Stacks] combine");