#!/gnu/usr/bin/perl 

#perl htmlgen.pl xml.dat

$index = shift;
$inform = 0;
open(INDEX, $index) || die "$0: can't open $index: $!\n";
while(<INDEX>) {
    s/\n//;
    $XML = $_;
    $HTML = $XML;
    $HTML =~ s:\.xml:\.html:;
    print "$XML -> $HTML\n";
    $c = "msxsl -i $XML -s warlpiri.xsl -o $HTML";
    $d = `$c`;
    if($d =~ m/Parse/i) {
        print STDERR "$d\n";
    }
    $c = "rm $XML";
    $d = `$c`;
    $inform++;
    if(($inform % 500) == 0) {
        print STDERR "$inform files converted\n";
    }
}
