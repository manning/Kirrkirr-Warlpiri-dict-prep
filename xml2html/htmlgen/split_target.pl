#!/usr/local/bin/perl 

#perl split_target html.dat
# now just builds the index

$index = shift;
$DEBUG = 0;
if($index =~ m/-D/) {
    $index = shift;
    $DEBUG = 1;
}


# this should print index.html
open(FILE, ">index.html") || die "$0: can't open index.html: $!\n";
print STDERR "printing index.html\n";
print FILE<<"Head";
<HTML>
<HEAD>
<TITLE>Index of words</TITLE>
</HEAD>
<BODY BGCOLOR="#F0F0F0" LINK="#6E6761" VLINK="#551A8B">
<OL>
Head
;

open(INDEX, $index) || die "$0: can't open $index: $!\n";
while ($HTML = <INDEX>) {
    chop $HTML;
    if ($HTML =~ /@(.+)@(.*)\.html/) {
	if ($2 eq "") {
	    print FILE "<LI><A HREF=\"$HTML\">$1</A>\n";
	} else {
	    print FILE "<LI><A HREF=\"$HTML\">$1 ($2)</A>\n";
	}
    } else {
	print STDERR "Oops!  Internal error - didn't match\n";
    }
}
close(INDEX);
print FILE<<"Tail";
</OL>
</BODY>
</HTML>
Tail
;
close(FILE);
