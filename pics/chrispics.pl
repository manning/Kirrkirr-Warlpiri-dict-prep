#!/usr/local/bin/perl

# chris' version of pics -- uses ones hand-coded in images.dat.  Just does a reversal

$input = shift;
$output = shift;

open(FILE, $input) || die "$0: can't open $input: $!\n";
while($line = <FILE>) {
    chop($line);
    @things = split("#", $line);
    $fname = shift(@things);
    $desc = shift(@things);
    print STDERR "$fname -- $desc\n";
    while ($word = shift(@things))
    {
	$pics{$word} =  $fname . ":" . $pics{$word};
    }
}
close(FILE);

open(NEW, ">$output") || die "$0: can't open $output: $!\n";
foreach $w (keys %pics) {
    print NEW "$w#$pics{$w}\n";
}
close(NEW);
