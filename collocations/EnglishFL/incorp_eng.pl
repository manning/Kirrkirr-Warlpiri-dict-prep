#!/gnu/usr/bin/perl

if($#ARGV <= 0) {
    print "Usage: perl incorp_eng.pl <file with Warlpiri> <results file>\n\n";
    exit 0;
}

$dict = shift;
$new = shift;

load_data();
open(FILE, $dict) || die "$0: can't open $dict: $!\n";
open(NEW, ">$new") || die "$0: can't open $new: $!\n";
$inform = 0;
while(<FILE>) {
    @words = split /\s+/;
    foreach $x (@words) {
        $word = $x;
	$word =~ s/-//g;
	$word =~ s/\n//g;
        if(defined $english{$word}) {
            print NEW "$word \($english{$word}\)\t";
        }
        else {
            print NEW "$x\t";
        }
    }
    print NEW "\n";
}
close(NEW);
close(FILE);

# load_data()
#
sub load_data {
    open(COUNT, "english.dat") || die "$0: can't open english.dat: $!\n";
    while (<COUNT>) {
        s/\n//g;
        ($key, $value) = split /#/;
        $english{$key} = $value;
        $total++;
    }
    close(COUNT);
}

