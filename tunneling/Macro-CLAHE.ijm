j=nSlices();
for (i=1; i<j; i++) {
  setSlice(i);
  run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
}
