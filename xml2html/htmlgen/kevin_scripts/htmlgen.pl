#!/gnu/usr/bin/perl 

#perl htmlgen.pl xml.dat

$index = shift;
$DEBUG = 0;
if($index =~ m/-D/) {
    $index = shift;
    $DEBUG = 1;
}


$inform = 0;
open(INDEX, $index) || die "$0: can't open $index: $!\n";
while(<INDEX>) {
    s/\n//;
    $XML = $_;
    $HTML = $XML;
    $HTML =~ s:\.xml:\.html:;
    print "$XML -> $HTML\n";
    $c = "msxsl -i \"$XML\" -s warlpiri.xsl -o \"$HTML\"";
    $d = `$c`;
    if(($d =~ m/Parse/i)||($d =~ m/Arguments/i)) {
        print STDERR "$d\n";
    }
    if($DEBUG == 0) {
        $c = "rm \"$XML\"";
    }
    $d = `$c`;
    $inform++;
    if(($inform % 500) == 0) {
        print STDERR "$inform files converted\n";
    }
}
