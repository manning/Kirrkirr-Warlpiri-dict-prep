#!/gnu/usr/bin/perl 

# this splits the large XML into separate XML files - one for each dictionaty entry
# NB: make sure the <?XML ...> and <DICTIOANRY> headers are removed off th big file before using this script
# The file names are made AAA.xml to ZZZ.xml so that the next scripts can be used with something like
# perl script.pl ???.xml and the files will be supplied to ARGV *in order*

$file = shift;
    
open(XMLS, ">xml.dat") || die "$0: can't open xml.dat: $!\n";
open(HTMLS, ">html.dat") || die "$0: can't open html.dat: $!\n";
open(FIXS, ">fix.dat") || die "$0: can't open fix.dat: $!\n";

$A = 65;
$B = 65;
$C = 65;
$x = pack "C", $A;
$y = pack "C", $B;
$z = pack "C", $C;
print XMLS "$x$y$z.xml\n";
print HTMLS "$x$y$z.html\n";
print FIXS "$x$y$z.html.fix\n";
$current = "$x$y$z.xml";
$finish = 0;

open(FILE, $file) || die "$0: can't open $file: $!\n";
open(CURRENT, ">$current") || die "$0: can't open $current: $!\n";
print CURRENT '<?XML version="1.0" encoding="ISO-8859-1"?>'."\n";
print CURRENT '<DICTIONARY>'."\n";
$/ = "";                                #this means one (\n separated) parargraph is read in at a time
while(<FILE>) {
    print CURRENT $_;
    #$finish= 1;
    #if(($finish==1)&&(m:\<\/ENTRY\>:)) {
        makeNewFile();
    #}
}
print CURRENT '</DICTIONARY>'."\n";
close(CURRENT);
close(FILE);
close(XML);
close(HTMLS);
close(FIXS);

sub makeNewFile {
    print CURRENT '</DICTIONARY>'."\n";
    close(CURRENT);
    $cont = 1;

    while($cont) {
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
        $name = "$x$y$z";
        if(($name =~ m/AUX/)||($name =~ m/CON/)) {        #these are reserved words in windows AUX.* and CON.*
            print "skipped $x$y$z\n";
            next;
        } else {
            $cont = 0;
        }

        print XMLS "$x$y$z.xml\n";
        print HTMLS "$x$y$z.html\n";
        print FIXS "$x$y$z.html.fix\n";
        $current = "$x$y$z.xml";
        $finish = 0;
        open(CURRENT, ">$current") || die "$0: can't open $current: $!\n";
        print CURRENT '<?XML version="1.0" encoding="ISO-8859-1"?>'."\n";
        print CURRENT '<DICTIONARY>'."\n";
    }
}

