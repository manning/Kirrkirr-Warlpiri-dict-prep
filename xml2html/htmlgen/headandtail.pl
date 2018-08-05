#!/usr/local/bin/perl 

# this removes the head and tail from the large XML file and stores them

$file = shift;
$DEBUG = 0;
if($file =~ m/-D/) {
    $file = shift;
    $DEBUG = 1;
}
    
open(XMLH, ">head.dat") || die "$0: can't open head.dat: $!\n";
open(XMLT, ">tail.dat") || die "$0: can't open tail.dat: $!\n";
open(XMLB, ">body.xml") || die "$0: can't open body.xml: $!\n";

open(FILE, $file) || die "$0: can't open $file: $!\n";
$beginning = 1;
$ending = 0;
while($line = <FILE>) {
    $written = 0;
    if ($beginning) {
	print XMLH $line;
	$written = 1;
    }
    if ($line =~ /<DICTIONARY>/) {
	$beginning = 0;
    }
    if ($line =~ /<\/DICTIONARY>/) {
	$ending = 1;
    }
    if ($ending) {
	print XMLT $line;
	$written = 1;
    }
    if (! $written) {
	print XMLB $line;
    }
}
close(XMLH);
close(XMLT);
close(XMLB);
close(FILE);
