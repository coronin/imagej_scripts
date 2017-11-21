//dir="/Users/liang/Downloads/"; // 分析文件保存的文件夹，win用\\替代/
dir=getDirectory("current"); // 分析文件保存当前图片文件夹

// 拖拉三个文件进程序
selectWindow("img_000000000_TxRed_000.tif"); // 抗体染核内点的通道
rename("R");
selectWindow("img_000000000_GFP_000.tif"); // GFP表达的通道，区分 rescue etc
rename("G");
selectWindow("img_000000000_DAPI_000.tif"); // 核区的通道
rename("B");
run("Merge Channels...", "c1=R c2=G c3=B keep");
selectWindow("RGB");
getDateAndTime(year,month,dayOfWeek,dayOfMonth,hr,min,sec,msec);
rnd=''+year+'-'+(month+1)+'-'+dayOfMonth+'-'+hr+'-'+min+'-'+sec; // 起头两个单引号表明这是一个字符串，注意月份是0开始
saveAs("Jpeg", dir+rnd+"_RGB.jpg"); // 存下压缩版本的图片备份
wait(200); // 可放慢 微秒
close();

// 制作核区mask
selectWindow("B");
call("ij.plugin.frame.ThresholdAdjuster.setMode", "Red");
setAutoThreshold("Otsu dark"); // 有可能需要调成非黑的，肯定需要拖拉覆盖大部分核
// Threshold快捷键 T
// 定义快捷键，比如 F12 "Create Mask"
while (isOpen("mask")!=true) {
  wait(1000);
  showStatus("Please make mask for nuclear ROIs First");
}
selectWindow("mask");
rename("Bmask");
run("Erode"); // 缩去掉毛刺的信号 
run("Close-"); // 补边
run("Fill Holes"); // 补洞
run("Erode");
run("Erode");
run("Close-"); // 补边
run("Fill Holes"); // 补洞
run("Dilate");
run("Dilate");
run("Dilate"); // 完成了：缩三 扩三

// 以下，以细胞核大小9999来设计，size=5000-40000 circularity=0.33-1.00 找核，1-5000 circularity=0.01-1.00 找核内点

selectWindow("Bmask");
roiManager("Show All"); // 标记所有找到的分析区域
run("Set Measurements...", "area mean min bounding display redirect=None decimal=1");
run("Analyze Particles...", "size=5000-40000 circularity=0.33-1.00 show=Nothing display exclude clear add"); // display 列出找到区域，clear 清除之前残余测量，add 生成ROI列表
found=nResults;
selectWindow("B");
roiManager("multi-measure measure_all"); // 没有append 覆盖之前测量，基于ROI的测法可以加上测量区域标签
selectWindow("R");
roiManager("multi-measure measure_all append"); // 积累不同通道
selectWindow("G");
roiManager("multi-measure measure_all append"); // 积累不同通道

// dilate the mask to measure G with some cytoplasm signal
selectWindow("Bmask");
saveAs("Jpeg", dir+rnd+"_Bmask.jpg");
rename("Bmask");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate");
run("Dilate"); // 扩十 希望包括了靠近细胞核的细胞质，有可能需要调整
run("Set Measurements...", "area mean min display bounding redirect=G decimal=1"); // 注意redirect
run("Analyze Particles...", "size=5000-40000 circularity=0.33-1.00 show=Nothing display"); // 注意这里取消了边界排除，因为扩大的操作，索性收下所有数据；这里没有冲刷ROI列表
selectWindow("Results");
saveAs("Results", dir+rnd+"_Otsu-Results.csv"); // close();

selectWindow("G");
close();
selectWindow("B");
close();
selectWindow("Bmask");
wait(200); // 可放慢 微秒
close();

// visit each ROI to measure internal dots
run("Set Measurements...", "area mean min display redirect=None decimal=1");
for (i=0; i<found; i++) {
  selectWindow("R");
  roiManager("Select", i);
  setAutoThreshold("Otsu dark");
  wait(100); // 可放慢 微秒
  run("Analyze Particles...", "size=1-5000 circularity=0.01-1.00 summarize");
}
roiManager("Delete");
resetThreshold();
selectWindow("Summary");
saveAs("Results", dir+rnd+"_OtsuOtsu-Summary.csv"); // close();

// Liang Cai
// i@cailiang.net
// 2017-9-6