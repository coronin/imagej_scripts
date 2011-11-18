// Liang Cai created for barbed end assay
// For RGB tif file
//
// adjust 787 with your microscopy setting
//
// measure R G B channel presented by 0 1 2
// ratio Blue to Green, presented by 4
// ratio Blue to Red, presented by 5
// ratio Green to Red, presented by 6
//
// 2011-11-16, v1.1.1 with NaN bug fix
// demo image at  http://dogeno.us/code/EdgeRatio.zip
// how to use at  http://knol.google.com/k/how-to-use-imagej-to-quantify-fluorescent-distribution
//
// 2008-1-27, used for 100x epi GA GW raw value, 
// 2007-08-19 add two more ratios
// 2006-11-16 new scale for 60x OCAR confocal 638==50
//
// 2007.3.12
//
// Illustrated by "Expand/Shrink Selection"
// Michael Schmid, version 05-Nov-2004

macro "MeasureEdge-RGB" {
	requires("1.34m");
	run("Clear Results");
  
// inputs for the macro
	steppix = 2; // expand or shrink per pix during the measure
	distance = 36; // total +/- distance from the edge, in pix

	Dialog.create("How to measure the edge");
	Dialog.addMessage("To measure the edge of a cell:");
	Dialog.addMessage(" 1. select the region you want to analyze and create a mask");
	Dialog.addMessage(" 2. use threshold and wand tool to outline the cell and create another mask");
	Dialog.addMessage(" 3. use the excel to graph the result");
	
	Dialog.addNumber("Step Pixal per Measure:", steppix);
	Dialog.addNumber("Total Pixal Distance:", distance);
	Dialog.show();
	steppix = Dialog.getNumber();
	distance = Dialog.getNumber();

	if ((distance % steppix) > 0) {
		exit("Remainder must be 0!");
	}

// initiate array
	realpair = distance / steppix;
	counts = realpair * 2 + 1;
// realpair + 1 + 4 + one more
	RealCount = minOf((realpair + 7),counts);

	title = getTitle();
	RGB = newArray("red", "green", "blue");
	yMin = newArray(255,255,255);
	yMax = newArray(0,0,0);

// creat data from shrinked/expanded mask, smaller to bigger, do 3 times for RGB
// run("Create Mask"); use other way to get Mask!!

	selectWindow(title);
	run("RGB Split");
	rename("blue");
	wait(140);
	run("Put Behind [tab]");
	rename("green");
	wait(140);
	run("Put Behind [tab]");
	rename("red");
	wait(140);
	run("Put Behind [tab]");	

	run("RGB Merge...", "red=red green=green blue=blue keep");
	run("Enhance Contrast", "saturated=0.5");

setTool(2);

	stepone = 0;
	while (isOpen("Mask")!=true && stepone == 0) {
		wait(1000);
		showStatus("Please Make Mask for ROI First");
	}
	selectWindow("Mask");
	rename("ROI-red");
	run("Duplicate...", "title=ROI-green");
	run("Duplicate...", "title=ROI-blue");
	stepone = 1;

	selectWindow("RGB");
	run("8-bit");
	run("Enhance Contrast", "saturated=0.5 normalize");

setTool(8);

	while (isOpen("Mask")!=true && stepone == 1) {
		wait(1000);
		showStatus("Please Make Mask First");
	}

	selectWindow("RGB");
	close();


	i = 0;
	while (i < RealCount) {
		selectWindow("Mask");
		run("Duplicate...", "title=MaskRun");
		if ((i - realpair) > 0) {
			selectWindow("MaskRun");
			run("Maximum...", "radius="+((i - realpair) * steppix));
			selectWindow("MaskRun");
			run("Outline");
		}
		else if ((i - realpair) == 0) {
			selectWindow("MaskRun");
			run("Outline");
		}
		else {
			selectWindow("MaskRun");
			run("Minimum...", "radius="+((realpair - i) * steppix));
			selectWindow("MaskRun");
			run("Outline");
		}

		selectWindow("MaskRun");
		rename("MaskRun-red");
		run("Duplicate...", "title=MaskRun-green");
		run("Duplicate...", "title=MaskRun-blue");
	
		for(rgbcycle=0; rgbcycle<3; rgbcycle++) {
			run("Image Calculator...", "image1=MaskRun-"+RGB[rgbcycle]+" operation=AND image2="+RGB[rgbcycle]);
			run("Image Calculator...", "image1=MaskRun-"+RGB[rgbcycle]+" operation=AND image2=ROI-"+RGB[rgbcycle]);
			setThreshold(1, 255);
			run("Set Measurements...", "area standard mean limit redirect=None decimal=2");
			selectWindow("MaskRun-"+RGB[rgbcycle]);
			run("Measure");

			callSD = getResult("StdDev", (nResults - 1));
			callN = getResult("Area", (nResults - 1));
			SEM = callSD / sqrt(callN);

			// 787 pix == 50 um
			xValues = ((i - realpair) * steppix) * 50 / 787;
			yValues = getResult("Mean", (nResults - 1));
			if ( !isNaN(yValues) ) {
				yMin[rgbcycle] = minOf(yMin[rgbcycle], yValues); 
				yMax[rgbcycle] = maxOf(yMax[rgbcycle], yValues);
			}

			yMin[rgbcycle] = minOf(yMin[rgbcycle], yValues);
			yMax[rgbcycle] = maxOf(yMax[rgbcycle], yValues);

			setResult("RGB-channel", (nResults - 1), rgbcycle);
			setResult("Distance", (nResults - 1), xValues);
			setResult("Intensity", (nResults - 1), yValues);
			setResult("SemOfInt", (nResults - 1), SEM);

			close();
		}

		i ++;
		updateResults();
	}

	selectWindow("Mask");
	close();
	selectWindow("ROI-red");
	close();
	selectWindow("ROI-green");
	close();
	selectWindow("ROI-blue");
	close();

	run("RGB Merge...", "red=red green=green blue=blue");

// ratio Blue to Green, presented by 4
// ratio Blue to Red, presented by 5
// ratio Green to Red, presented by 6

	i = 0;
	while (i < RealCount) {
		for(j=0; j<3; j++) {
			setResult("PercInt", (i*3+j), ((getResult("Mean", (i*3+j)) - yMin[j]) / (yMax[j] - yMin[j])) );
			setResult("PercSEM", (i*3+j), (getResult("SemOfInt", (i*3+j)) / (yMax[j] - yMin[j])) );
			setResult("b2g-Ratio", (i*3+j), (getResult("Mean", (i*3 + 2)) / getResult("Mean", (i*3 + 1))) );
			setResult("b2r-Ratio", (i*3+j), (getResult("Mean", (i*3 + 2)) / getResult("Mean", (i*3))) );
			setResult("g2r-Ratio", (i*3+j), (getResult("Mean", (i*3 + 1)) / getResult("Mean", (i*3))) );
		}
		i ++;
	}
	updateResults();

	selectWindow("Results");
	saveAs("Measurements", getDirectory("current")+"RatioE-"+ substring(title, 3, (lengthOf(title)-4)) +".xls");

	wait(1000);
	close();
}