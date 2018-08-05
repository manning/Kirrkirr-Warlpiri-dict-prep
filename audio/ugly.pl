#!/gnu/usr/bin/perl 

$debug = 1;

if($#ARGV <= 0) {
    print "Usage: perl ugly.pl\n\n";
    exit 0;
}

open(FILE, "codes.log") || die "$0: can't open codes.log: $!\n";
while(<FILE>) {
    s/\n//g;
    ($key, $value) = split /#/;
    $code2word{$key} = $value;
}      
close(FILE);

while(@ARGV) {
    $file = shift @ARGV;
    $code = $file;
    $code =~ s/\.\w+$//;
    $b = "mv $file $code2word{$code}";
    $c = `$b`;
    #print "$b\n";
}
