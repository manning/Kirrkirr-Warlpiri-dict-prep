#!/gnu/usr/bin/perl 

#usage: perl runner.pl <xmlfile with no headers - see split.pl>

$xmlfile = shift;
$DEBUG = "";
if($xmlfile =~ m/-D/) {
    $xmlfile = shift;
    $DEBUG = "-D";
}

print "running html generation ... \n";
$b = "perl split.pl $DEBUG $xmlfile";
$c = `$b`;
print "xml files split\n";
$b = "perl htmlgen.pl $DEBUG xml.dat";
$c = `$b`;
print "html generated\n";
$b = "perl splitfix.pl $DEBUG html.dat";
$c = `$b`;
print "html fixed\n";
$b = "perl split_target.pl $DEBUG fix.dat";
$c = `$b`;
print "hyperlinks updated\n";

