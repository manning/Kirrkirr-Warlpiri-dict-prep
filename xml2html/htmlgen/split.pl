#!/usr/local/bin/perl 

# this splits the large XML into separate XML files - one for each 
# dictionary entry 
# chris: now re-uses original header and footer, rather than hardcoding
# them in this file!

$file = shift;
$DEBUG = 0;
if($file =~ m/-D/) {
    $file = shift;
    $DEBUG = 1;
}
    
open(XMLS, ">xml.dat") || die "$0: can't open xml.dat: $!\n";
open(HTMLS, ">html.dat") || die "$0: can't open html.dat: $!\n";
open(FIXS, ">fix.dat") || die "$0: can't open fix.dat: $!\n";

open(FILE, $file) || die "$0: can't open $file: $!\n";
$/ = "";                                #this means one (\n separated) parargraph is read in at a time
while(<FILE>) {
    if(m/^\s*$/) { 
        next;
    }
    $entry = $_;
    $word = $_;
    if($word =~ m/\<HW(.*?)\>(.+?)\<\/HW\>/) {
        $hnum = $1;
        $word = $2;
        if($hnum =~ m/HNUM\=\"(\d+)\"/) {
            $hnum = $1;
        } else {
            $hnum = "";
        }
    } else {
        next;
    }
    $fname = '@'.$word.'@'.$hnum;
    
    open(CURRENT, ">$fname.xml") || die "$0: can't open $fname.xml: $!\n";
    # print header
    open(XMLH, "head.dat") || die "$0: can't open head.dat: $!\n";
    while ($line = <XMLH>) {
	print CURRENT $line;
    }
    close(XMLH);
    print CURRENT $entry;
    # print footer
    open(XMLT, "tail.dat") || die "$0: can't open tail.dat: $!\n";
    while ($line = <XMLT>) {
	print CURRENT $line;
    }
    close(XMLT);
    close(CURRENT);

    print XMLS "$fname.xml\n";
    print HTMLS "$fname.html\n";
    print FIXS "$fname.html.fix\n";
}

close(FILE);
close(XML);
close(HTMLS);
close(FIXS);
if ($DEBUG == 0) {
    $c = "rm head.dat tail.dat \"$file\"";
    $d = `$c`;
}
