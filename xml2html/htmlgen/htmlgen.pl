#!/usr/local/bin/perl 

#usage: perl htmlgen.pl [-D] xml.dat

$XSL = "../XT/warlpiri.xsl";
# The other thing you will probably need to change is the $command command
# below command should take $XML and $XSL as input and produce $HTML

$index = shift;
$DEBUG = 0;
if($index =~ m/-D/) {
    $index = shift;
    $DEBUG = 1;
}

$inform = 0;
open(INDEX, $index) || die "$0: can't open $index: $!\n";
while ($XML = <INDEX>) {
    chop($XML);
    $HTML = $XML;
    $HTML =~ s:\.xml$:\.html:;
    print "$XML -> $HTML\n";
    $command = "./runxt.csh \"$XML\" \"$XSL\" \"$HTML\"";
    # $command = "msxsl -i \"$XML\" -s $XSL -o \"$HTML\"";
    $d = `$command`;
    if($DEBUG && ($d =~ m/Parse/i)||($d =~ m/Arguments/i)||
       ($d =~ m/exception/i)) {
        print STDERR "$d\n";
    }
    if($DEBUG == 0) {
        $c = "rm \"$XML\"";
	$d = `$c`;
    }
    $inform++;
    if(($inform % 500) == 0) {
        print STDERR "$inform files converted\n";
    }
}
