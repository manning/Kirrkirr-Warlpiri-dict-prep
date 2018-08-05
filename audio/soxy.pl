#!/gnu/usr/bin/perl 

$debug = 0;
$verbose = 0;

if($#ARGV <= 0) {
    print "Usage: perl soxy.pl <list of files with old extension (eg .ross>\n";
    print "       makes au files with same names using SOX\n";
    exit 0;
}

$A = 65;
$B = 65;
$C = 65;
$x = pack "C", $A;
$y = pack "C", $B;
$z = pack "C", $C;
$code = "$x$y$z";

while(@ARGV) {
    $file = shift @ARGV;
    $word = $file;
    $word =~ s/\.\w+$//;
    $word =~ s/_//g;
    $code2word{$code} = $word;
    $b = "mv $file $code.aif";
    if($debug) {
        print "$b\n";
    } else {
        $c = `$b`;
        print "$b\n" if $verbose;
    }
    $b = 'sox '.$code.'.aif -r 8012 -U -b '.$code.'.au';
    if($debug) {
        print "$b\n";
    } else {
        $c = `$b`;
        print "$b\n" if $verbose;
    }
    $b = "cp $code.au $word.au";
    if($debug) {
        print "$b\n";
    } else {
        $c = `$b`;
        print "$b\n" if $verbose;
    }
    $b = "rm $code.aif";
    if($debug) {
        print "$b\n";
    } else {
        $c = `$b`;
        print "$b\n" if $verbose;
    }
    $C++;
    if($C > 90) {
        $C = 65;
        $B++;
    }
    if($B > 90) {
        $B = 65;
        $A++;
    }
    $x = pack "C", $A;
    $y = pack "C", $B;
    $z = pack "C", $C;
    $code = "$x$y$z";
}

open(FILE, ">codes.log") || die "$0: can't open codes.log: $!\n";
foreach $code (keys %code2word) {
    print FILE "$code#$code2word{$code}\n";
}
close(FILE);

