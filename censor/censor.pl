#!/usr/local/bin/perl

# this leaves out badwords -- or any specified words to produce a subset
# dictionary

# perl censor.pl badwords.dat input.xml output.xml

if($#ARGV < 2) {
    print "Usage: perl censor.pl <bad.dat> <xml-in> <xml-out>\n";
    exit 0;
}

$bad = shift;
$dict = shift;
$new = shift;

load_data($bad);
open(FILE, $dict) || die "$0: can't open $dict: $!\n";
open(NEW, ">$new") || die "$0: can't open $new: $!\n";
$inform = 0;
$purge = 0;
while(<FILE>) {
    if (/^<ENTRY.*>([^<>]+)<\/HW>/) {
	if ($badword{$1}) {
	    $purge++;
	    print STDERR "Purged $1\n";
	    do {
	    } while (<FILE> !~ /<\/ENTRY>/);
	    # go on to next blank line
	    $_ = <FILE>;
	}
	$inform++;
	if ($inform % 1000 == 0) {
	    print STDERR "$inform entries processed.\n";
	}
    }
    print NEW;
}        
close(NEW);
close(FILE);
print STDERR "$purge entries purged.\n";


# load_data()
# 
sub load_data {
    $fname = shift;
    open(BAD, $fname) || die "$0: can't open $fname: $!\n";
    while(<BAD>) {
	chop;
	$badword{$_} = 1;
    }      
    close(BAD);
}
