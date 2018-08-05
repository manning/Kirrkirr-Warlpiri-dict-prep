#!/gnu/usr/bin/perl 

$file = shift;
$newfile = shift;
    
open(FILE, $file) || die "$0: can't open $file: $!\n";
while(<FILE>) {
    if(m:\<a name=\"\"\>\<P\>\<H3\>(.+?)\<\/H3\>:) {
        print "$1\n";
        $location{$1} = $.;
    }
}
$lines = $.;
close FILE;

print "$lines\n";
$CONST = 0.01;
foreach $w (keys %location) {
    $location{$w} = ($location{$w}-($location{$w}*$CONST))/$lines;
}

open(FILE, $file) || die "$0: can't open $file: $!\n";
open(NEW, ">$newfile") || die "$0: can't open $newfile: $!\n";
while(<FILE>) {
    if(m:\<a name=\"\"\>\<P\>\<H3\>(.+?)\<\/H3\>:) {
        print NEW $`;
        print NEW '<a name="'.$location{$1}.'"><P><H3>'.$1.'</H3>';
        print NEW $';
    }
    else {
        s:\<a href=\"\"\>(.+?)\<\/a\>:\<a href=\"\#$location{$1}\"\>$1\<\/a\>:gi;
        print NEW $_;
    }
}
close FILE;
close NEW;