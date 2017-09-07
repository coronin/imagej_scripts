#!/usr/bin/perl
# by cail
# input file is the results from ImageJ (angle and length)
# convert the angle and length from the ImageJ measurement
# to protrusion/retraction rate and protursion duration
# ignore the data if the length smaller than 10 pixel
# angle between -0 to -90 is considered to be protrusion
# angle between -90 to -180 is considered to be retraction
# output rate is um per min, duration is min
#
# cail 2006-05-25 version 6
# length collect the max and the min, and only accept the
# data between [max-(max-min)*0.05] and 
#  [min+(max-min)*0.05]
# for angle is the same, but based on the grouped data
# CANNOT use the distribution of sample means !
#
# cail 2006-05-26 version 7
# cail 2012-05-28 adjust for liu @ duan lab
# cail 2016-6-1 for #pgt
#
# command run
#
# perl KymoRate_liu.pl XXX.txt


use strict;
use warnings;
use Math::Trig;

my $input = $ARGV[0];
if ($input =~ /\//) {print "txt and pl files should be in the same folder!"; exit;}
if ($input =~ /\\/) {print "txt and pl files should be in the same folder!"; exit;}

my @filedata = ();
unless( open(GET_FILE_DATA, $input) ) {
	print "Cannot open file \"$input\"\n";
	exit;
}

@filedata = <GET_FILE_DATA>;
close GET_FILE_DATA;

my $proNum = 0;
my $retNum = 0;
my @proRate = 0;
my @proDuration = 0;
my @proDistance = 0;
my @retRate = 0;
my @retDuration = 0;
my @retDistance = 0;
my $lengthMax = 1000; # @@@@
my $lengthMin = 3; # @@@@
my $angleProMax = 0; # @@@@
my $angleProMin = 90; # @@@@
my $angleRetMax = 0; # @@@@
my $angleRetMin = 90; # @@@@

foreach my $line (@filedata) { # screen for max and min
	if ($line =~ /\t-([0-9]+\.?[0-9]*)\t([0-9]+\.?[0-9]*)\s$/) {	
		my $angle = 90 - $1;
		my $length = $2;
		if ($length > $lengthMax) {$lengthMax = $length;}
		if ($length < $lengthMin) {$lengthMin = $length;}
		
		if ($angle > 0 && $angle < 90) {
			if ($angle > $angleProMax) {$angleProMax = $angle;}
			if ($angle < $angleProMin) {$angleProMin = $angle;}
			next;
		}
		if ($angle < 0 && $angle > -90) {
			my $angleT = 0 - $angle;
			if ($angleT > $angleRetMax) {$angleRetMax = $angleT;}
			if ($angleT < $angleRetMin) {$angleRetMin = $angleT;}
			next;
		}
	}
}

my $pixelper50um = 528.5; # "309" pixel equal to 50 microns @@@@ !
my $timeinterval = 0.5; # "1" sec per pixel shift - kymo line width is 1 and movie is 1 sec interval @@@@ !
my $data_range = 1; # = 0.95 means filter 0.95 * xx + 0.05 * yy @@@@
my $MaxL = $data_range * $lengthMax + (1 - $data_range) * $lengthMin;
my $MinL = $data_range * $lengthMin + (1 - $data_range) * $lengthMax;
my $MaxPa = $data_range * $angleProMax + (1 - $data_range) * $angleProMin;
my $MinPa = $data_range * $angleProMin + (1 - $data_range) * $angleProMax;
my $MaxRa = $data_range * $angleRetMax + (1 - $data_range) * $angleRetMin;
my $MinRa = $data_range * $angleRetMin + (1 - $data_range) * $angleRetMax;

# @@@@ no need to change anything below

foreach my $line (@filedata) { # creat the real data
	if ($line =~ /\t-([0-9]+\.?[0-9]*)\t([0-9]+\.?[0-9]*)\s$/) {	
		my $angle = 90 - $1;
		my $length = $2;
		if ($length < 4) { # make sure 10 pixel length rule
			next;
		}
		if ($length < $MinL) { # filter rule
			next;
		}
		if ($length > $MaxL) { # filter rule
			next;
		}
		if ($angle > 0 && $angle < 90) {
			if ($angle < $MinPa) { # filter rule
				next;
			}
			if ($angle > $MaxPa) { # filter rule
				next;
			}
			$proRate[$proNum] = 3000 * tan( pi * $angle / 180) / ($pixelper50um * $timeinterval);
			$proDuration[$proNum] = $length * cos( pi * $angle / 180) * $timeinterval / 60;
			$proDistance[$proNum] = $length * sin( pi * $angle / 180) * 50 / $pixelper50um;
			$proNum ++;
			next;
		}
		if ($angle < 0 && $angle > -90) {
			my $angleT = 0 - $angle;
			if ($angleT < $MinRa) { # filter rule
				next;
			}
			if ($angleT > $MaxRa) { # filter rule
				next;
			}
			$retRate[$retNum] = 3000 * tan( pi * $angleT / 180) / ($pixelper50um * $timeinterval);
			$retDuration[$retNum] = $length * cos( pi * $angleT / 180) * $timeinterval / 60;
			$retDistance[$retNum] = $length * sin( pi * $angleT / 180) * 50 / $pixelper50um;
			$retNum ++;
			next;
		}
	}
}

@proRate = sort { $a <=> $b } @proRate;
@proDuration = sort { $a <=> $b } @proDuration;
@proDistance = sort { $a <=> $b } @proDistance;

@retRate = sort { $a <=> $b } @retRate;
@retDuration = sort { $a <=> $b } @retDuration;
@retDistance = sort { $a <=> $b } @retDistance;

my $output = 'M#-' . $input;
open(OUTPUT, ">$output");
print OUTPUT "==========\nProtrusion Rate (um/min)\n";
print OUTPUT "$_\n" for @proRate;
print OUTPUT "\n==========\nProtrusion Duration (min)\n";
print OUTPUT "$_\n" for @proDuration;
print OUTPUT "\n==========\nProtrusion Distance (um)\n";
print OUTPUT "$_\n" for @proDistance;
print OUTPUT "\n----------\nRetraction Rate (um/min)\n";
print OUTPUT "$_\n" for @retRate;
print OUTPUT "\n----------\nRetraction Duration (min)\n";
print OUTPUT "$_\n" for @retDuration;
print OUTPUT "\n----------\nRetraction Distance (um)\n";
print OUTPUT "$_\n" for @retDistance;
close(OUTPUT);
exit();