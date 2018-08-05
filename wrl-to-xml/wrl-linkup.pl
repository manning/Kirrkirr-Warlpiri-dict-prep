#!/usr/local/bin/perl

# runs as a filter.  XML <-> ASCII

$lnum = 0;

while ($line = <>)
{
    $lnum++;
    if ($line =~ /<HW[^>]*>(.*)<\/HW>/)
    {
	$word = $1;
	print "$word\n";
    }
}
