#!/usr/bin/perl
# by cail 2006-05-25
# run a perl program with input in line
# for all the files in a directory

opendir($DIR,".");
@filelist = readdir($DIR);

foreach my $filename (@filelist) {
	print "$filename\n";
	if ($filename =~/\.txt$/) { # @@@@
		system("perl KymoRate_liu.pl \"$filename\""); # @@@@
	}
}
