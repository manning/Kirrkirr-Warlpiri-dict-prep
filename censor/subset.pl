#!/usr/local/bin/perl

# this includes only good words

# perl subset.pl goodwords.dat input.xml output.xml

if($#ARGV < 2) {
    print "Usage: perl subset.pl <good.dat> <xml-in> <xml-out>\n";
    exit 0;
}

$good = shift;
$dict = shift;
$new = shift;

load_data($good);
open(FILE, $dict) || die "$0: can't open $dict: $!\n";
open(NEW, ">$new") || die "$0: can't open $new: $!\n";
$inform = 0;
$selected = 0;
while($line = <FILE>) {
    if ($line =~ /^<ENTRY.*>([^<>]+)<\/HW>/) {
	if ($goodword{$1}) {
	    $selected++;
	    print STDERR "Selected $1\n";
	    do {
		print NEW $line;
		$line = <FILE>
	    } while ($line !~ /<\/ENTRY>/);
	    print NEW $line;
	    # go on to next blank line
	    $line = <FILE>;
	    print NEW $line;
	}
	$inform++;
	if ($inform % 1000 == 0) {
	    print STDERR "$inform entries processed.\n";
	}
    } elsif ($line =~ /<\?xml/) {
	print NEW $line;
    } elsif ($line =~ /<\/?DICTIONARY>/) {
	print NEW $line;
    }
}        
close(NEW);
close(FILE);
print STDERR "$selected entries selected.\n";


# load_data()
# 
sub load_data {
    $fname = shift;
    open(GOOD, $fname) || die "$0: can't open $fname: $!\n";
    while(<GOOD>) {
	chop;
	$goodword{$_} = 1;
    }      
    close(GOOD);
}
