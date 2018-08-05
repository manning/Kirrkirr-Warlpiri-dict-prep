#!/usr/local/bin/perl

if ($#ARGV < 0)
{
    die "Needs a word to look for!\n";
}
$string = $ARGV[0];
$textbase = "/usr/local/corpora/text/Warlpiri";
$texta = "$textbase/texts-jhs";
$textb = "$textbase/texts-laughren";

system("grep '$string' $texta/*");
system("grep '$string' $texta/*/*");
system("grep '$string' $texta/*/*/*");

system("grep '$string' $textb/*/*");
system("grep '$string' $textb/*/*/*");
system("grep '$string' $textb/*/*/*/*");
system("grep '$string' $textb/*/*/*/*/*");
system("grep '$string' $textb/*/*/*/*/*/*");
