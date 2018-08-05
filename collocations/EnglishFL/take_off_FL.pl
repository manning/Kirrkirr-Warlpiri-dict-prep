#!/gnu/usr/bin/perl

#remove the FL tags from the gloss fields

$dict = shift;
$new = shift;

open(FILE, $dict) || die "$0: can't open $dict: $!\n";
open(NEW, ">$new") || die "$0: can't open $new:$!\n";
$inform = 0;
while(<FILE>) {
    if(m/^\<GL\>/) {
        s/\<FL\>//g;
        s/\<\/FL\>//g;
        print NEW;
    } else {
        print NEW;
    }
    $inform++;
    if(($inform % 30000)==0) {
        print "$inform lines processed\n";
    }          	
}
close(NEW);
close(FILE);
