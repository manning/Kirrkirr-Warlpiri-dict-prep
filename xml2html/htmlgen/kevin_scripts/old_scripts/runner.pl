#!/gnu/usr/bin/perl 

#usage: perl runner.pl <xmlfile with no headers - see split.pl>

$xmlfile = shift;
print "running html generation ... \n";
$b = "perl split.pl $xmlfile";
$c = `$b`;
print "xml files split\n";
$b = "perl htmlgen.pl xml.dat";
$c = `$b`;
print "html generated\n";
$b = "perl splitfix.pl html.dat";
$c = `$b`;
print "html fixed\n";
$b = "perl split_target.pl fix.dat";
$c = `$b`;
print "hyperlinks updated\n";

