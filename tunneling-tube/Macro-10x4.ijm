run("Enhance Contrast...", "saturated=0.1 normalize process_all");
run("Stack Splitter", "number=2");

run("Merge Channels...", "c1=stk_0002_Pos0 c2=stk_0001_Pos0 keep");
run("Combine...", "stack1=stk_0001_Pos0 stack2=stk_0002_Pos0 combine");
selectWindow("Combined Stacks");
