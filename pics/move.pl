#!/gnu/usr/bin/perl 

$debug = 1;

if($#ARGV <= 0) {
    print "Usage: perl move.pl <extension> <list of files with old extension>\n\n";
    exit 0;
}

$ext = shift;

while(@ARGV) {
    $w = shift @ARGV;
    $x = $w;
    $x =~ s/\.\w+$/\.$ext/;
    $b = "mv $w $x";
    $c = `$b`;
    #print "$b\n";
}
