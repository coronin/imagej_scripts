/* Liang Cai
   i@cailiang.net
   2017-9-6,7 */
//dir="/Users/liang/Downloads/"; // 分析文件保存的文件夹，win用\\替代/
//dir="D:\\wj\\";
dir=getDirectory("current"); // 分析文件保存当前图片文件夹，但有时拖拉打开不记录所在文件夹

// 拖拉三个文件进程序
selectWindow("img_000000000_TxRed_000.tif"); // 抗体染核内点的通道
rename("R");
selectWindow("img_000000000_GFP_000.tif"); // GFP表达的通道，区分 rescue etc
rename("G");
selectWindow("img_000000000_DAPI_000.tif"); // 核区的通道
rename("B");
run("Merge Channels...", "c1=R c2=G c3=B keep");
selectWindow("RGB"); // 留着RGB帮助抹去不合适的核区
getDateAndTime(year,month,dayOfWeek,dayOfMonth,hr,min,sec,msec);
rnd=''+year+'-'+(month+1)+'-'+dayOfMonth+'-'+hr+'-'+min+'-'+sec; // 起头两个单引号表明这是一个字符串，注意月份是0开始
saveAs("Jpeg", dir+rnd+"_RGB.jpg"); // 存下压缩版本的图片备份
rename("RGB");

// 制作核区mask
run("Tile");
selectWindow("B");
call("ij.plugin.frame.ThresholdAdjuster.setMode", "Red");
setAutoThreshold("Otsu dark"); // 有可能需要调成非黑的，肯定需要拖拉覆盖大部分核
// Threshold快捷键 T
// 定义快捷键，比如 F12 "Create Mask"
run("Colors...", "foreground=black background=black selection=yellow");
setTool("rectangle"); // 用删除区域的方法去掉不需要的数据
while (isOpen("mask")!=true) {
  wait(1000);
  showStatus("Please make mask for nuclear ROIs First");
}
selectWindow("mask");
rename("Bmask");
run("Erode"); // 缩去掉毛刺的信号
run("Erode");
run("Erode");
run("Close-"); // 补边
run("Fill Holes"); // 补洞
run("Dilate");
run("Dilate");
run("Dilate"); // 完成了：缩三 扩三

// 以下，以细胞核大小9999来设计，size=5000-40000 circularity=0.33-1.00 找核，1-5000 circularity=0.01-1.00 找核内点

selectWindow("Bmask");
run("Set Measurements...", "area mean min bounding display redirect=None decimal=1");
run("Analyze Particles...", "size=5000-40000 circularity=0.33-1.00 show=Nothing display exclude clear add"); // display 列出找到区域，clear 清除之前残余测量，add 生成ROI列表
found=nResults;
roiManager("Show All without labels"); // 标记所有找到的分析区域
selectWindow("B");
roiManager("multi-measure measure_all"); // 没有append 覆盖之前测量，基于ROI的测法可以加上测量区域标签
selectWindow("R");
roiManager("multi-measure measure_all append"); // 积累不同通道
selectWindow("G");
roiManager("multi-measure measure_all append"); // 积累不同通道

selectWindow("RGB");
close();
selectWindow("B");
close();
selectWindow("Bmask");
roiManager("Show All with labels");
run("Flatten");
saveAs("Jpeg", dir+rnd+"_Bmask.jpg");
wait(200); // 可放慢 微秒
close();
close();

// visit each ROI to measure internal dots
run("Set Measurements...", "area mean min bounding display redirect=None decimal=1");
for (i=0; i<found; i++) {
  selectWindow("R");
  rename("R-"+i);
  roiManager("Select", i);
  setAutoThreshold("Otsu dark");
  wait(100); // 可放慢 微秒
  run("Analyze Particles...", "size=1-5000 circularity=0.01-1.00 summarize");
  rename("R");
  selectWindow("G");
  roiManager("Select", i);
  run("Duplicate...", " ");
  selectWindow("G-1");
  rename("G-"+i);
  run("Select All");
  run("Measure");
  close();
}
selectWindow("R");
close();
selectWindow("G");
close();
selectWindow("Summary");
saveAs("Results", dir+rnd+"_OtsuOtsu-Summary.csv");

// reset things
roiManager("Delete");
run("Colors...", "foreground=white background=black selection=yellow");

// 新建数据列 G-Mean G-Percentage G-outsideMean
gMax=0;
gMin=65535;
gTmp=0;
selectWindow("Results");
for (i=0; i<found; i++) {
  gTmp = getResult("Mean", (found*2+i));
  gMin = minOf(gMin, gTmp);
  gMax = maxOf(gMax, gTmp);
}
i = 0;
while (i<found) {
  gTmp = getResult("Mean", (found*2+i));
  gOut = (getResult("Mean", (found*3+i)) * getResult("Area", (found*3+i)) - gTmp * getResult("Area", (found*2+i))) / (getResult("Area", (found*3+i)) - getResult("Area", (found*2+i)));
  for(j=0; j<3; j++) {
    setResult("G-Mean", (j*found+i), gTmp);
    setResult("G-Percentage", (j*found+i), ((gTmp-gMin)*100/(gMax-gMin)));
    setResult("G-outsideMean", (j*found+i), gOut);
  }
  i++;
}
updateResults();
saveAs("Results", dir+rnd+"_Otsu-Results.csv");
