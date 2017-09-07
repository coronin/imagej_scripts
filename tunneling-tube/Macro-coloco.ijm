dr="20140922-HeLa-150x-GAAX+Golgi.TagRFP-500ms-cell3_1";
ct="14";
ch1="Golgi"+ct;
ch2="tube-"+ct;

open("/Users/liang/Nutstore/#pgt/数据处理/双色定量/Golgi/"+dr+"/"+ch1+".tif");
open("/Users/liang/Nutstore/#pgt/数据处理/双色定量/Golgi/"+dr+"/"+ch2+".tif");

run("Coloc 2", "channel_1="+ch1+".tif channel_2="+ch2+".tif roi_or_mask=<None> threshold_regression=Bisection spearman's_rank_correlation kendall's_tau_rank_correlation");
selectWindow(ch1+".tif");
close();
selectWindow(ch2+".tif");
//close();
selectWindow("Log");
saveAs("Text", "/Users/liang/Desktop/cell1-item"+ct+".txt");
