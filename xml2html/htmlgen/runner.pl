#!/usr/local/bin/perl 

#usage: perl runner.pl [-D] xml-file

$xmlfile = shift;
$DEBUG = "";
if($xmlfile =~ m/-D/) {
    $xmlfile = shift;
    $DEBUG = "-D";
}

print "Starting html generation ... \n";
system("perl headandtail.pl $DEBUG $xmlfile");
print "head and tail removed\n";

system("perl split.pl $DEBUG body.xml");
print "xml files split\n";

system("perl htmlgen.pl $DEBUG xml.dat");
print "html generated\n";

# system("perl splitfix.pl $DEBUG html.dat");
# print "html fixed\n";

system("perl split_target.pl $DEBUG html.dat");
print "index created ... Finished\n";

if ($DEBUG eq "") {
    $c = "rm xml.dat fix.dat html.dat";
    $d = `$c`;
}
