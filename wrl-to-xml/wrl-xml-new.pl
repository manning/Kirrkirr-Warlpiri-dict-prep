#!/usr/bin/perl

# use strict;
use feature 'unicode_strings';
use utf8;

# Warlpiri -> XML
# A complicated regexp matching hack, now complete with a stack-based parser

# Christopher Manning .. July 1998

# TODO:
#     - Better CT processing -- it can be multiple words!
#	<DEF>bottom part of a hill (<CT HENTRY="?">ngarnka, pirli</CT>)</DEF>
#     - Do real \rv reversal list handling.

# updated .. August 1998.  Growing subroutines.
# 8 aug 98 - now good dialect handling
# 9 aug 98 - more general
# 5oct98 - rewritten to be stack based; fix subentries, etc.
# nov 98 - some more fixes and extensions
# jan 99 - a new version that treats subentries differently as full entries
# 		with cross references.  (Done somewhat crudely...)
# 18jan99 - make it able to produce either old or new output format
#		do checking of headword nubmers
# 23jan99 - one last try: 3 passes so HNUM's are always right
# 23 mar 99 - one minor bug fix
# 16 may 99  - another minor bug fix. split gloss and crossref also on ;
#	        remove duplicate entry by hand
# june 99 - unifying me/sse, and fixes
# 29 june 99 - do case insensitive xref; get gloss from XME
# july 99 - make compatible with xsl processors
# 26 jul 99 - put HENTRY info into CT, and other minor fixes
# 27 jul 99 - much improve copying of gloss over xme
# 23 dec 99 - fix parsing of crossreference word followed by source <SRC>
#		code to fix three more typos/errors
# mar 00 - do cross-ref for DOMI items. 
#		Check to fill in current word in CT
# aug 18 - updated for all the new stuff in wlp-lexicon_master.txt
#               Improved treatment of < > in various places; improve matching of PVL
#
# usage: [changed for new version (no longer a filter as read file twice)]
#	wrl-xml-new.pl filename [0/1] >xmlfilename

# GLOBAL VARIABLES
# $kevinformat	0 = regular, 1 = promote subentries to entries,
#	dm = print semantic domain info.  Read from $ARGV[1] if present
# $truehnum = real exact hnum of current (sub)word
# See also associative arrays below

$kevinformat = 1;
if ($#ARGV < 0 || $#ARGV > 1)
{
    print STDERR "usage: wrl-xml-new.pl filename [0/1/dm]\n";
    exit(0);
}
if ($#ARGV > 0)
{
    $kevinformat = $ARGV[1];
    if ($kevinformat eq "dm")
    {
	&semdomains;
	exit(0);
    }
}

# -- New stuff to go through first and collect xrefs -- 

## Associative arrays built:
##
## $easyspell{$reducedword} = $hw;	# reduced word leaves out punctuation
## $subwords{$hw/$hnum} = "subentry1, subentry2" # no entry for subhw
## $xrefs{"$hw/$hnum"} = "list of words (formatting unimportant, just grep it)"
## $hnumcnt{$hw} = n   n is the highest so far assigned hnum for that word
## $hnummcnt{$hw} = n   Duplicate of above, counted up on 2nd/3rd pass through.

&buildhnumcnts($ARGV[0]);

open(INPUT, '<:encoding(UTF-8)', $ARGV[0]) || die "Couldn't open $ARGV[0]\n";

while ($line = <INPUT>)
{
    &fixupline(0);

    if ($line =~ /^@/)
    {
        # Skip as comment
    }
    # \me Main entry lines
    elsif ($line =~ /^\\me +([-=a-zA-Z()]+ ?[-=a-z()]+)[ *]/)
    {
	$hw=$1;
	$currhead = $hw;

	&entereasyhw($hw);

	if ($hnummcnt{$hw})
	{
	    $truehnum = $hnummcnt{$hw} + 1;
	}
	else
	{
	    $truehnum = 1;
	}
	$hnummcnt{$hw} = $truehnum;
	$currtruehnum = $truehnum;
    }
    elsif ($line =~ /^\\sse/)
    {
	if ($line =~ /^\\sse *<CT>/)
	{
	    $line =~ s/<\/?CT[^>]*>//g;
	}
	if ($line =~ /^\\sse +([-=a-zA-Z()]+ ?[A-Z)-]*[-=a-z()]+)( *\*[0-9#]+\*)? /)
	{
	    $hw=$1;
	    $hnum=&trimwhite($2);

	    &entereasyhw($hw);

	    if ($hnummcnt{$hw})
	    {
		$truehnum = $hnummcnt{$hw} + 1;
	    }
	    else
	    {
		$truehnum = 1;
	    }
	    $hnummcnt{$hw} = $truehnum;

	    $key = "$currhead/$currtruehnum";
	    $temp = $hw;
	    if ($hnumcnt{$hw} > 1)
	    {
		$temp .= "*$truehnum*";
		# print STDERR "### temp = |$temp|\n";
	    }
	    if ($subwords{$key} eq "")
	    {
		$subwords{$key} = $temp;
	    }
	    else
	    {
		$subwords{$key} = "$subwords{$key}, $temp";
	    }
	    # print STDERR "For $currhead, subwords: $subwords{$currhead}\n";
	}
    }
    elsif ($line =~ /^\\(cf|alt|syn|ant|pvl|see|xme|xsse)/)
    {
	$xmekey = "$hw/$truehnum";
	chop($line);
	if ($line =~ /\\[a-z]+( .*)\\[a-z]+ */)
	{
	    $line = $1;
	}
	$xrefs{$xmekey} .= $line;
    }
    elsif ($line =~ /^\\gl /)
    {
	$xmekey = "$hw/$truehnum";
	$string = &standardhandling($line, "gl", 0);
	if ($string ne "")
	{
	    # store first (most general sense) if several
	    if ($glosses{$xmekey} eq "")
	    {
		# print STDERR "Storing for |$xmekey| $string\n";
		$glosses{$xmekey} = $string;
	    }
	}
    }
    elsif ($line =~ /^\\glo/)
    {
	$xmekey = "$hw/$truehnum";
	$string = &standardhandling($line, "glo", 0);
	if ($string ne "")
	{
	    # store first (most general sense) if several
	    if ($glosses{$xmekey} eq "")
	    {
		# print STDERR "Storing for |$xmekey| $string\n";
		$glosses{$xmekey} = $string;
	    }
	}
    }
    elsif ($line =~ /^\\rv/)
    {
	$xmekey = "$hw/$truehnum";
	$string = &standardhandling($line, "rv", 0);
	if ($string ne "")
	{
	    # store first (most general sense) if several
	    if ($glosses{$xmekey} eq "")
	    {
		# print STDERR "Storing for |$xmekey| $string\n";
		$glosses{$xmekey} = $string;
	    }
	}
    }
}

close(INPUT);
# delete the hnummcnt has and reuse later
%hnummcnt = ();


# -- Original main processor begins here -- 

open(INPUT, $ARGV[0]) || die "Couldn't open $ARGV[0]\n";

# state variables
$entry = "[Beginning]";
$lnum = 0;
@instack = ();
# for filling in of XME glosses
$xmeref = "";
$xmenum = 0;
$glossed = 0;
$glossedStr = "";  # records what glosslike things seen for me|sse: o = glo, r = rv g = gl

# dictionary header - now not done in script again
print "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
print "<?xml-stylesheet type=\"text/xsl\" href=\"warlpiri.xsl\"?>\n";
print "<DICTIONARY>\n";

while ($line = <INPUT>)
{
    $lnum++;
    # remember the uncorrupted line for error reports
    $oline = $line;

    &fixupline(1);

#    if ($line =~ /^\\([a-z]+)/)
#    {
#	print STDERR "Line $lnum is $1, stack is @instack\n";
#    }

    if ($line =~ /^@/)
    {
        # Skip as comment
    }
    # \me Main entry lines
    elsif ($line =~ /^\\me /)
    {
	&closeallopen;
	push(@instack, "pme");	# the pseudo me that continues past \eme
	push(@instack, "me");

	($hw, $hnum, $pos, $pos2, $source, $source2, $remarks, $deriv, $crit, $dialect) = &parseentryline("me", $line);
	$mentry = $entry;	# so sse can find it
	if ($hw ne "")
	{
	    if ($hnummcnt{$hw})
	    {
		$truehnum = $hnummcnt{$hw} + 1;
	    }
	    else
	    {
		$truehnum = 1;
	    }
	    $hnummcnt{$hw} = $truehnum;
	    $mhnum = $truehnum;

	    if ($hnum ne "")
	    {
	        if ($hnum =~ /\*([0-9#]+)\*/)
	        {
		    $hnum = $1;
	        }
		if ($hnum < $truehnum)
		{
		    print STDERR "$lnum, entry $entry, hnum: bad for $hw.  Should be >= $truehnum not $hnum\n\t$oline";
		}
	    }
	    elsif ($truehnum > 1)
	    {
		print STDERR "$lnum, entry $entry, hnum: bad for $hw.  Should be >= $truehnum not missing\n\t$oline";
	    }

	    if ($kevinformat && $hnumcnt{$hw} > 1)
	    {
		# use truehnum
		print "<ENTRY><HW HNUM=\"$truehnum\">$hw</HW>\n";
	    }
	    elsif (! $kevinformat && $hnum ne "")
	    {
	        print "<ENTRY><HW HNUM=\"$hnum\">$hw</HW>\n";
	    }
	    else
	    {
	        print "<ENTRY><HW>$hw</HW>\n";
	    }
	    if ($pos ne "")
	    {
		print "<POS>$pos</POS>\n";
	    }
	    if ($pos2 ne "")
	    {
		print "<POS>$pos2</POS>\n";
	    }
	    &printdialects($dialect, 1);
            if ($deriv ne "")
	    {
	        print "<DERIV>$deriv</DERIV>\n";
	    }
            if ($remarks ne "")
	    {
	        print "<REM>$remarks</REM>\n";
	    }
            if ($source ne "")
	    {
	        print "$source\n";
	    }
	    if ($kevinformat)
	    {
		# write the subentries corresponding to main
		$key = "$hw/$truehnum";
		if ($subwords{$key} ne "")
		{
		    &seealsodecode($subwords{$key}, "SE");
		}
	    }
	}
	else
	{
	    # nevertheless treat as new entry
	    print "<ENTRY>\n";
	}
	
    }
    elsif ($line =~ /^\\eme/)
    {
	&heuristicclose("me", "main entry sense");
	# treat as no-op so that we put subentries inside main entry
	&endnotrail($line);
    }
    elsif ($line =~ /^\\(cf|alt|syn|ant|pvl|see|xme|xsse) /)
    {
	&closeexamples;
	$what = $1;
	$uwhat = $what;
	$uwhat =~ tr/a-z/A-Z/;
	if ($what eq "see")
	{
	    print STDERR "$lnum, entry $entry, cf: see used instead of cf [corrected!]:\n\t$oline";
	    $uwhat = "CF";
	}
	$string = &standardhandling($line, $what, 1);
	if ($string ne "")
	{
	    &seealsodecode($string, $uwhat);
	}
    }
    # \se lines -- should use subroutine to share parts with me
    elsif ($line =~ /^\\se/)
    {
	if ($line =~ /^\\se *(.*)$/)
	{
	    $stuff1=$1;
	    if (&member("se", @instack))
	    {
		print STDERR "$lnum, entry $entry, se: nested se (missing ese?)\n\t$oline";
		&closeopensense;
	    }
	    push(@instack, "se");
	    print "<SENSE>\n";
	    &printsenserest($stuff1);
	}
	else
	{
	    print STDERR "$lnum, entry $entry, se: Couldn't handle:\n\t$oline";
	}
    }
    elsif ($line =~ /^\\ese/)
    {
	&heuristicclose("se", "sense");
	&endnotrail($line);
    }
    # \sub lines -- like \se should use subroutine to share parts with me
    elsif ($line =~ /^\\sub/)
    {
	if ($line =~ /^\\sub *(.*)$/)
	{
	    $stuff1=$1;
	    if (&member("sub", @instack))
	    {
		print STDERR "$lnum, entry $entry, sub: nested sub (missing esub?)\n\t$oline";
		# print "</SENSE>\n";
	    }
	    if (! &member("psse", @instack))
	    {
		print STDERR "$lnum, entry $entry, sub: doesn't belong to sse (should be se?)\n\t$oline";
	    }
	    push(@instack, "sub");
	    print "<SENSE>\n";
	    &printsenserest($stuff1);
	}
	else
	{
	    print STDERR "$lnum, entry $entry, sub: Couldn't handle:\n\t$oline";
	}
    }
    elsif ($line =~ /^\\esub/)
    {
	&heuristicclose("sub", "subsense");
	&endnotrail($line);
    }
    # \sse lines
    elsif ($line =~ /^\\sse/)
    {
	if ($kevinformat)
	{
	    &closeallopen;
	}
	else
	{
	    &closemostopen;
	}
	push(@instack, "psse");
	push(@instack, "sse");
	if ($line =~ /^\\sse *<CT/)
	{
	    print STDERR "$lnum, entry $entry, sse: Shouldn't have Warlpiri in brackets on sse line [corrected!]:\n\t$oline";
	    $line =~ s/<\/?CT[^>]*>//g;
	}
	$glossed = 0;
	$glossedStr = "";

	($hw, $hnum, $pos, $pos2, $source, $source2, $remarks, $deriv, $crit, $dialect) = &parseentryline("sse", $line);
	if ($hw ne "")
	{
	    if ($hnummcnt{$hw})
	    {
		$truehnum = $hnummcnt{$hw} + 1;
	    }
	    else
	    {
		$truehnum = 1;
	    }
	    $hnummcnt{$hw} = $truehnum;

	    if ($hnum ne "")
	    {
	        if ($hnum =~ /\*([0-9#]+)\*/)
	        {
		    $hnum = $1;
	        }
		if ($hnum < $truehnum)
		{
		    print STDERR "$lnum, entry $entry, hnum: bad for $hw.  Should be >= $truehnum not $hnum\n\t$oline";
		}
	    }
	    elsif ($truehnum > 1)
	    {
		print STDERR "$lnum, entry $entry, hnum: bad for $hw.  Should be >= $truehnum not missing\n\t$oline";
	    }

	    if ($kevinformat)
	    {
		# giving TYPE="SUB" twice is a bit nasty but happens for
		# historical reasons.  Kirrkirr uses one in HW.
		if ($hnumcnt{$hw} > 1)
		{
		    # use truehnum
		    print "<ENTRY TYPE=\"SUB\"><HW HNUM=\"$truehnum\" TYPE=\"SUB\">$hw</HW>\n";
		}
		else
		{
		    print "<ENTRY TYPE=\"SUB\"><HW TYPE=\"SUB\">$hw</HW>\n";
		}
	    }
	    else
	    {
		if ($hnum ne "")
		{
		    print "<SUBENTRY><HW HNUM=\"$hnum\" TYPE=\"SUB\">$hw</HW>\n";
		}
		else
		{
		    print "<SUBENTRY><HW TYPE=\"SUB\">$hw</HW>\n";
		}
	    }

	    if ($pos ne "")
	    {
		print "<POS>$pos</POS>\n";
	    }
	    if ($pos2 ne "")
	    {
		print "<POS>$pos2</POS>\n";
	    }
	    &printdialects($dialect, 1);
            if ($deriv ne "")
	    {
	        print "<DERIV>$deriv</DERIV>\n";
	    }
            if ($crit ne "")
	    {
	        print "<CRITERION>$crit</CRITERION>\n";
	    }
            if ($remarks ne "")
	    {
	        print "<REM>$remarks</REM>\n";
	    }
            if ($source2 ne "")
	    {
	        print "$source2\n";
	    }
            if ($source ne "")
	    {
	        print "$source\n";
	    }
	    if ($kevinformat)
	    {
		# put in back ref
		print "<CME><CMEI HENTRY=\"$mentry\"";
		if ($hnumcnt{$mentry} > 1)
		{
		    print " HNUM=\"$mhnum\"";
		}
		print ">$mentry</CMEI></CME>\n";
	    }
	}
    }
    elsif ($line =~ /^\\esse/)
    {
	&endnotrail($line);
	&heuristicclose("sse", "sse");
    }
    elsif ($line =~ /^\\(lato|lat|rul|refa|ref|cmp|def|cm|csl|xs|note) /)
    {
	$what = $1;
	$uwhat = $what;
	$uwhat =~ tr/a-z/A-Z/;
	$string = &standardhandling($line, $what, 1);
	if ($string ne "")
	{
	    print "<$uwhat>$string</$uwhat>\n";
	}
    }
    elsif ($line =~ /^\\pdx/)
    {
	if (&member("pdx", @instack))
        {
	    print STDERR "$lnum, entry $entry, pdx: Examples inside examples (missing \\epdx?)\n\t$oline";
	    # print "</PDX>\n";
        }
	push(@instack, "pdx");
	if ($line =~ s/\\ecm *$//)
	{
	    print STDERR "$lnum, entry $entry, pdx: unexpected \\ecm at end of line [deleted!]\n\t$oline";
	    # print "</PDX>\n";
        }
	if ($line =~ /^\\pdxs? +(\([A-Za-z,]*\))?([^(].*)$/)
	{
	    # I don't really separately handle \pdxs yet (has wrl word)
	    $dialect = $1;
	    $rest = $2;
	    print "<PDX>\n";
	    &printdialects($dialect, 1);
	    $rest = &trimwhite($rest);
	    if ($rest ne "")
	    {
		print "<CRITERION>$rest</CRITERION>\n";
	    }
	}
	else
	{
	    print STDERR "$lnum, entry $entry, pdx(s): Couldn't handle:\n\t$oline";
	}
    }
    elsif ($line =~ /^\\epdx/)
    {
	&endnotrail($line);
	&heuristicclose("pdx", "paradigm examples");
    }
    elsif ($line =~ /^\\eg/)
    {
	if (&member("eg", @instack))
        {
	    print STDERR "$lnum, entry $entry, eg: Examples inside examples (missing \\eeg?)\n\t$oline";
	    # print "</EXAMPLES>\n";
	    # pop(@instack);
        }
	&endnotrail($line);
	print "<EXAMPLES>\n";
	push(@instack, "eg");
    }
    elsif ($line =~ /^\\eeg/)
    {
	&endnotrail($line);
	&heuristicclose("eg", "examples");
    }
    elsif ($line =~ /^\\we/)
    {
	if ($instack[$#instack] eq "we")
        {
	    print STDERR "$lnum, entry $entry, we(d): previous we not ended with ewe\n\t$oline";
	    &heuristicclose("we", "Warlpiri example");
        }
	elsif ($instack[$#instack] ne "eg")
        {
	    print STDERR "$lnum, entry $entry, we(d): we(d) not inside example\n\t$oline";
        }
	if ($line =~ /^\\we(d?) +(.*)\\ewed? *$/)
	{
	    $matchd = $1;
	    $cont = $2;
	    $gotend = 1;
	}
	elsif ($line =~ /^\\we(d?) +(.*)/)
	{
	    push(@instack, "we");
	    $matchd = $1;
	    $cont = $2;
	    $gotend = 0;
	}
	else
	{
	    print STDERR "$lnum, entry $entry, we(d): Couldn't handle:\n\t$oline";
	    push(@instack, "we");
	    $matchd = "";
	    $cont = "";
	    $gotend = 0;
	}
	if ($matchd eq "d")
	{
	    print "<EXAMPLE><WE TYPE=\"DEFN\">";
	}
	else
	{
	    print "<EXAMPLE><WE>";
	}
	print "$2</WE>\n";
	if ($gotend)
	{
	    print "</EXAMPLE>\n";
	}
    }
    elsif ($line =~ /^\\et/)
    {
	if (! &member("eg", @instack))
        {
	    print STDERR "$lnum, entry $entry, et: et not inside example\n\t$oline";
        }
	if ($line =~ /^\\et +(.*)\\ewed? *\\ewed? *$/)
	{
	    print STDERR "$lnum, entry $entry, et: too many \\ewe(d) at end of line [corrected!]\n\t$oline";
	    $trans = &trimwhite($1);
	    print "<ET>$trans</ET>";
	    &heuristicclose("we", "Warlpiri example");
	}
	elsif ($line =~ /^\\et +(.*)\\ewed? *$/)
	{
	    $trans = &trimwhite($1);
	    print "<ET>$trans</ET>";
	    &heuristicclose("we", "Warlpiri example");
	}
	elsif ($line =~ /^\\et +(.*)\\eeg$/)
	{
	    $trans = &trimwhite($1);
	    print "<ET>$trans</ET>";
	    &heuristicclose("we", "Warlpiri example");
	    print STDERR "$lnum, entry $entry, et: missing \\ewe(d) at end of line [corrected!]\n\t$oline";
	    &heuristicclose("eg", "examples");
	}
	elsif ($line =~ /^\\et +(.*)$/)
	{
	    $trans = &trimwhite($1);
	    print "<ET>$trans</ET>";
	}
	elsif ($line =~ /^\\et *$/)
	{
	    print STDERR "$lnum, entry $entry, et: malformed (no?) translation:\n\t$oline";
	    print "<ET></ET>";
	}
	else
	{
	    print STDERR "$lnum, entry $entry, et: couldn't handle (missing ewe?):\n\t$oline";
	}
    }
    elsif ($line =~ /^\\ewe/)
    {
	if (! &member("eg", @instack))
	{
	    print STDERR "$lnum, entry $entry, ewe: ewe outside example block\n\t$oline";
	}
	&endnotrail($line);
	&heuristicclose("we", "Warlpiri example");
    }
    elsif ($line =~ /^\\epvl/)
    {
	print STDERR "$lnum, entry $entry, epvl: not on end of pvl line [omitted!]\n\t$oline";
    }
    elsif ($line =~ /^\\dm/)
    {
	$string = &standardhandling($line, "dm", 1);
	if ($string ne "")
	{
	    &printdomain($string);
	}
    }
    elsif ($line =~ /^\\gl /)
    {
	$string = &standardhandling($line, "gl", 1);
	if ($string ne "")
	{
	    &printgloss($string, "gl");
	    $glossed = 1;
	    $glossedStr = $glossedStr . "g";
	}
    }
    elsif ($line =~ /^\\glo /)
    {
	$string = &standardhandling($line, "glo", 1);
	if ($string ne "")
	{
	    &printgloss($string, "glo");
	    $glossed = 1;
	    $glossedStr = $glossedStr . "o";
	}
    }
    elsif ($line =~ /^\\rv /)
    {
	$string = &standardhandling($line, "rv", 1);
	if ($string ne "")
	{
	    &printgloss($string, "rv");
	    $glossed = 1;
	    $glossedStr = $glossedStr . "r";
	}
    }
    elsif ($line =~ /^\\(org) /)
    {
	$what = $1;
	$uwhat = $what;
	$uwhat =~ tr/a-z/A-Z/;
	$string = &standardhandling($line, $what, 1);
	if ($string ne "")
	{
	    print "<$uwhat>$string</$uwhat>\n";
	}
    }
    elsif ($line =~ /^[ \t]*$/)
    {
	# blank line is okay!
    }
    else
    {
	print STDERR "$lnum, entry $entry, unk: Couldn't handle:\n\t$oline";
    }
}
		
# final completion
&closeallopen;
# dictionary footer
print "</DICTIONARY>\n";


sub seealsodecode 
# first parameter is a string of "word, word, word" format
# second parameter is a string for basis of tag, eg. "ALT"
# this routine depends on splitting on /, / being adequate ...
# we try to fix any wrong ones given in sources
{
    local($str) = shift(@_);
    local($tag) = shift(@_);

    if ($str =~ /^<CT/)
    {
	print STDERR "$lnum, entry $entry, seealsodecode: Shouldn't have Warlpiri in brackets on $tag line [corrected!]:\n\t$oline";
	$str =~ s/<\/?CT[^>]*>//g;
    }
    if ($str =~ /,,/)
    {
	print STDERR "$lnum, entry $entry, seealsodecode: Typo: doubled comma on $tag line [corrected!]:\n\t$oline";
	$str =~ s/,,/, /g;
    }
    if ($str =~ /kardu-puka,lampunu-puka/)
    {
	print STDERR "$lnum, entry $entry, seealsodecode: Typo: missing space after comma on $tag line [corrected!]:\n\t$oline";
	$str =~ s/kardu-puka,lampunu-puka/kardu-puka, lampunu-puka/g;
    }
    if ($str =~ /\\([a-z]+) /)
    {
	print STDERR "$lnum, entry $entry, seealsodecode: error: embedded \\$1 on $tag line [corrected!]:\n\t$oline";
	$str =~ s/\\[a-z]+ / /;
    }
    print "<$tag>";
    # remove spaces after commas in <SRC>'s so the split will work okay!
    # do it twice, in case two commas (there are once!)
    $str =~ s/(<SRC>[^<]*,) +([^ ][^<]*<\/SRC>)/\1\2/;
    $str =~ s/(<SRC>[^<]*,) +([^ ][^<]*<\/SRC>)/\1\2/;
    # fix dialects with spaces between them!
    if ($str =~ /\), \([A-Z]/)
    {
	$str =~ s/\), \(([A-Z])/,\1/;
	print STDERR "$lnum, entry $entry, seealsodecode: Removed space between dialect names in:\n\t$oline";
    }
    # now treat ";" as comma - no loss of info for crossref, I think.
    $str =~ s/; /, /g;
    @fields = split(/, +/, $str);
    while ($thing = shift(@fields))
    {
	&printannword($thing, $tag);
        if ($#fields >= 0)
        {
	    print ", ";
        }
    }
    print "</$tag>\n";
}


sub printannword
{
    # can use $hw as a read only global variable
    local($str) = shift(@_);
    local($tag) = shift(@_);
    local($sense) = 0;
    local($hnum) = 0;
    local($dialect) = "";
    local($src) = "";
    local($verhw);

    $str = &trimwhite($str);
    if ($str =~ /^(.*){\?\?}$/)
    {
	$str = $1;
	print STDERR "$lnum, entry $entry, annword: warning, crossref followed by {??} [stripped]\n\t$oline";
    }
    if ($str =~ /^(.+)\.$/)
    {
	$str = $1;
	print STDERR "$lnum, entry $entry, annword: warning, crossref followed by '.' [stripped]\n\t$oline";
    }
    $str = &trimwhite($str);
    if ($str =~ /^(.*[^ ]) +(<SRC>.*<\/SRC>)$/)
    {
	$str = $1;
	$src = $2;
    }
    $str = &trimwhite($str);
    $dialect = "";
    while ($str =~ /^(.*[^ ]) +(\(.*\))$/)
    {
	$str = $1;
	$dialect = $2 . $dialect;
    }
    if ($str =~ /^(.*)%(.*)%$/)
    {
	$str = $1;
	$sense = $2;
    }
    if ($str =~ /^(.*)\*(.*)\*$/)
    {
	$str = $1;
	$hnum = $2;
    }
    if ($str =~ /^(.*)\?\?$/)
    {
	$str = $1;
	print STDERR "$lnum, entry $entry, annword: word followed by ?? [omitted!]\n\t$oline";
    }
    $str = &trimwhite($str);
    if ($str eq "")
    {
	print STDERR "$lnum, entry $entry, annword: missing word:\n\t$oline";
    }

    # check can be found or warn
    ($verhw, $hnum) = &verifyword($str, $hnum, 1);

    print "<${tag}I";
    if ($verhw)
    {
	print " HENTRY=\"$verhw\"";
	# take the first xme word (this loses 3 and gains 7 -- optimal
	# would be to put all of them in a list)
	if ($tag eq "XME" && $xmeref eq "")
	{
	    $xmeref = $verhw;
	    $xmenum = $hnum;
	}
    }
    if ($kevinformat)
    {
	# make sure there is an hnum iff appropriate
	if ($verhw ne "?" && $hnumcnt{$verhw} > 1)
	{
	    print " HNUM=\"$hnum\"";
	}
    }
    elsif ($hnum)
    {
	print " HNUM=\"$hnum\"";
    }
    if ($sense)
    {
	print " SNUM=\"$sense\"";
    }
    print ">$str";
    &printdialects($dialect, 0);
    if ($src ne "") 
    {
	print " $src";
    }
    print "</${tag}I>";
}


sub printdialects
# will also print registers
# can have the brackets still around it or not: (La,Y) or just Y
# or can have multiple brackets (La)(Y)
# if string passed in is empty, print nothing
# second arg is whether to print \n at end
{
    local($str) = shift(@_);
    local($newl) = shift(@_);

    $str = &trimwhite($str);
    if ($str ne "")
    {
	local($thing);
	local(@fields);
	local($register);
	local($prevreg) = "";

	# print STDERR "### str is $str\n";
	if ($str =~ /^\((.*)\)$/)
	{
	    $str = $1;
	}
	if ($str =~ /\(/)
	{
	    # This allows both, as in \me mumu (N): (La,Y) (BT)
	    @fields = split(/\) *\(|, */, $str);
        }
        else
	{
	    @fields = split(/, */, $str);
	}
	while ($thing = shift(@fields))
	{
	    if ($thing !~ /^(E|H|La|P|Wi|WW|Y|BT|SL|Ny)$/)
	    {
		print STDERR "$lnum, entry $entry, printdialects: Warning. $thing is an unknown dialect:\n\t$oline";
	    }
	    # Known dialects:
	    # E: Eastern Warlpiri
	    # H: Hansen River
	    # La: Lajamanu
	    # Ny: Nyirrpi
	    # P: Papunya
	    # Wi: Willowra (Wirliyajarrayi)
	    # WW: Wakirti Warlpiri (Alekarenge and Tenant Creek)
	    # Y: Yurntumu (Yuendumu)
	    # Known registers:
	    # BT: Baby Talk
	    # SL: Special Register Language
	    if ($thing =~ /BT|SL/)
	    {
		$register = "RG";
	    }
	    else
	    {
		$register = "DL";
	    }
	    if ($register ne $prevreg)
	    {
		# first time through, it is null
		if ($prevreg eq "RG")
		{
		    print "</REGISTERS>";
		}
		elsif ($prevreg eq "DL")
		{
		    print "</DIALECTS>";
		}
		if ($register eq "RG")
		{
		    print "<REGISTERS>";
		}
		else
		{
		    print "<DIALECTS>";
		}
		$prevreg = $register;
	    }
	    else
	    {
		print ",";
	    }

	    print "<${register}I>$thing</${register}I>";
	}
	# unless an entry, it is null
	if ($prevreg eq "RG")
	{
	    print "</REGISTERS>";
	}
	elsif ($prevreg eq "DL")
	{
	    print "</DIALECTS>";
	}
	if ($newl)
	{
	    print "\n";
	}
    }
}

sub trimwhite
#remove whitespace from both ends
{
    local($str) = shift(@_);
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $str;
}

sub printdomain
{
    # only argument is the domain string
    local($str) = shift(@_);
    local($thing);
    local(@fields);

    print "<DOMAIN>";
    $str = &trimwhite($str);
    @fields = split(/: */, $str);
    while ($thing = shift(@fields))
    {
	print "<DMI";
	($dmword, $dmhnum) = verifyword($thing, "", 0);
        if ($dmword ne "?")
	{
	    print " HENTRY=\"$dmword\"";
	    if ($kevinformat && $hnumcnt{$dmword} > 1)
	    {
		print " HNUM=\"$dmhnum\"";
	    }
	    elsif ($dmhnum)
	    {
		print " HNUM=\"$dmhnum\"";
	    }
	}
        print ">$thing</DMI>: ";
    }
    print "</DOMAIN>\n";
}

sub printgloss
{
    local($str) = shift(@_);
    local($tag) = shift(@_);
    local($thing);
    local(@fields);
    local($orig);
    # uses global $glossedStr

    if ($tag =~ /rv/ && $glossedStr =~ /g|o/ ||
        $tag =~ /glo/ && $glossedStr =~ /g/)
    {
	return;
    }

    print "<GL>";
    $str = &trimwhite($str);
    # now treat ";" as comma - slight loss of info, here.
    s/; /, /g;
    # Need to get rid of and restore comma space in SRC
    if ($str =~ /(<SRC>[^<]+, [^<]+<\/SRC>)/)
    {
	$orig = $1;
	$str =~ s/(<SRC>[^<]+), ([^<]+<\/SRC>)/\1,\2/;
    }
    # Need to allow @, escaping of comma
    $str =~ s/@,/@@@@@@/g;
    @fields = split(/, +/, $str);
    while ($thing = shift(@fields))
    {
	# fix some cases where there is ", " within other tag scopes
	if ($thing =~ /\([^)]*$/ || 
	    $thing =~ /<SRC>/ && $thing !~ /<\/SRC>/)
	{
	    $thing .= ", ";
	    $thing .= shift(@fields);
	}
	$thing =~ s/@@@@@@/,/g;

        print "<GLI>$thing</GLI>";
        if ($#fields >= 0)
        {
	    print ", ";
        }
    }
    print "</GL>\n";
}

sub endnotrail
#checks there is nothing after an end tag
{
    local($str) = shift(@_);
    $str =~ /^\\([a-z]+)(.*)$/;
    local($tag) = $1;
    local($rest) = $2;
    $rest = trimwhite($rest);
    if ($rest ne "")
    {
	print STDERR "$lnum, entry $entry, $tag: Extra stuff unexpected after tag:\n\t$oline";
    }
}

sub standardhandling
# for any single line that should have begin and end tags, do standard checks
{
local($str) = shift(@_);
local($tag) = shift(@_);
local($showerrs) = shift(@_);
local($string) = "";

$str = &trimwhite($str);
if ($str =~ /^\\${tag} +(.*)\\e${tag}$/)
{
    $string = $1;
}
elsif ($str =~ /^\\${tag} +(.*)\\${tag}$/)
{
    if ($showerrs)
    {
	print STDERR "$lnum, entry $entry, $tag: \\$tag should be \\e$tag [corrected!]:\n\t$oline";
    }
    $string = $1;
}
elsif ($str =~ /^\\${tag} +(.*)(\\e[a-z]+)$/)
{
    if ($showerrs)
    {
	print STDERR "$lnum, entry $entry, $tag: $2 should be \\e$tag [corrected!]:\n\t$oline";
    }
    $string = $1;
}
elsif ($str =~ /^\\${tag} +(.*)\\e${tag}.+$/)
{
    if ($showerrs)
    {
	print STDERR "$lnum, entry $entry, $tag: Junk (?) after \\e$tag [omitted!]:\n\t$oline";
    }
    $string = $1;
}
elsif ($line =~ /^\\${tag} +(.*)$/)
{
    if ($showerrs)
    {
	print STDERR "$lnum, entry $entry, $tag: Missing \\e$tag [corrected!]:\n\t$oline";
    }
    $string = $1;
}
else
{
    if ($showerrs)
    {
	print STDERR "$lnum, entry $entry, $tag: Couldn't handle:\n\t$oline";
    }
}
$string = &trimwhite($string);
}

sub printsenserest
# decode sense POS, dialect, criterion
{
    local($str) = shift(@_);
    local($pos) = "";
    local($dialect) = "";

    if ($str =~ /\(([^)]+)\):(.*)$/)
{
    $pos = $1;
    $str = $2;
}
# there should really be a space in the char class, but it occurs sometimes
if ($str =~ /(\([A-Za-z, ]+\))(.*)$/)
{
    $dialect = $1;
    $str = $2;
}
if ($pos ne "")
{
    print "<POS>$pos</POS>\n";
}
&printdialects($dialect, 1);
$str = &trimwhite($str);
if ($str ne "")
{
    print "<CRITERION>$str</CRITERION>\n";
}
}

sub heuristicclose
# tries to close something when sees end tag.  Hopefully the right thing.
# uses @instack context global variable
{
    local($tag) = shift(@_);
    local($context) = shift(@_);

    if ($instack[$#instack] eq $tag)	# there are no problems
    {
	pop(@instack);
	&closeopen($tag, 0);
    }
    elsif ($#instack > 0 && $instack[$#instack -1] eq $tag) # missing close
    {
	$thing = pop(@instack);
	&closeopen($thing, 1);
	pop(@instack);
	&closeopen($tag, 0);
    }
    elsif ($tag =~ /(sse|se|sub|me)/ && $instack[$#instack] =~ /^(sse|se|sub)/)
    {
	# presumed mixup of tags
	$thing = pop(@instack);
        print STDERR "$lnum, entry $entry, e$tag: e$tag apparently closing a $thing [corrected!]\n\t$oline";
	&closeopen($thing, 0);
    }
    else
    {
        print STDERR "$lnum, entry $entry, e$tag: orphan e$tag not ending $context\n\t$oline";
    }
}


sub closeexamples
{
    local($item);

    while ($instack[$#instack] =~ /(eg|we)/)
    {
	$item = pop(@instack);
	&closeopen($item, 1);
    }
}


sub closeopensense
{
    local($item);

    do
    {
	$item = pop(@instack);
	&closeopen($item, 1);
    }
    until ($item eq "se");
}


sub closemostopen
{
    local($item);

    while ($instack[$#instack] =~ /(psse|sub|pdx|eg|we)/)
    {
	$item = pop(@instack);
	&closeopen($item, 1);
    }
}


sub closeallopen
{
    local($item);

    while ($item = pop(@instack))
    {
	&closeopen($item, 1);
    }
}


# change for kevinformat: sse ends entries
# (can't be just me because get senses after \eme

sub closeopen
{
    # parameters are: 1. tag, eg., "me"
    #		      2. iserror: 0 or 1 depending on whether to write errors

    local($item) = shift(@_);
    local($iserror) = shift(@_);
    local($key);
    local($xmegloss);

    # insert xme crossrefs as needed at end of sense
    # should possibly include pdx too, but not sure if systematic
    if ($item =~ /^me|sse|se|sub$/)
    {
	# print STDERR "@@@ $entry: glossed is $glossed, xmeref is $xmeref\n";
	if ($glossed == 0 && $xmeref ne "" && $xmeref ne "?")
	{
	    # print STDERR "@@@ $item this sense not glossed and has xme: $entry\n";
	    if ($xmenum == 0) 
	    {
		$xmenum = 1; # fix for 0 if only 1 case
	    }
	    $key = "$xmeref/$xmenum";
	    $xmegloss = $glosses{$key};
	    # print STDERR "@@@ glossed is $glossed, key is |$key|, xmegloss is $xmegloss.\n";
	    if ($xmegloss ne "")
	    {
		&printgloss($xmegloss);
	    }
	}
	$xmeref = "";
	$xmenum = 0;
	$glossed = 0;
    }

    # close pseudo or clean up closures
    if ($item eq "pme")
    {
	print "</ENTRY>\n\n";
    }
    elsif ($item eq "psse")
    {
	if ($kevinformat)
	{
	    print "</ENTRY>\n\n";
	}
	else
	{
	    print "</SUBENTRY>\n";
	}
    }
    else
    {
	if ($iserror)
	{
	    print STDERR "$lnum, entry $entry, $item: not ended before end of larger unit [corrected!]\n\t$oline";
	}
	if ($item eq "eg")
	{
	    print "</EXAMPLES>\n";
	}
	elsif ($item eq "we")
	{
	    print "</EXAMPLE>\n";
	}
	elsif ($item eq "pdx")
	{
	    print "</PDX>\n";
	}
	elsif ($item eq "se")
	{
	    print "</SENSE>\n";
	}
	elsif ($item eq "sub")
	{
	    print "</SENSE>\n";
	}
	elsif ($item eq "sse" || $item eq "me")
	{
	    # do nothing -- wait for psse or pme
	}
	else
	{
	    print STDERR "$lnum, entry $entry, Shouldn't happen: trying to close a $item\n";
	}
    }
}


sub member
{
    local($what) = shift(@_);
    local($found) = 0;

    foreach $thing (@_)
    {
	if ($thing eq $what)
	{
	    $found = 1;
	}
    }
    $found;
}

sub fixupline
{
    # this does all the initial global cleanup of lines read from the file
    # manipulates $line as a global variable (and $lnum, and $kevinformat)
    # Paramaters:
    #    1. show errors: 1 or 0

    local($showerr) = shift(@_);

    # global changes
    # remove repeated entry
    if ($line =~ /\\me -ngi \(Case\): \(H\)/)
    {
	while ($line !~ /^[ \t]*$/)
	{
	    $line = <INPUT>;
	}
    }
    # one off typo fixes
    if ($line =~ s/<Japara-kanyi</<Japara-kanyi>/ ||
	$line =~ s/<warukupalupalu</<warukupalupalu>/ ||
	$line =~ s/Jurnpurnpu>ngulaju/Jurnpurnpungulaju/ ||
	$line =~ s/walk talking long strides/walk taking long strides/ ||
	$line =~ s/([^l])<Capparis/\1\\l<Capparis/ ||
        $line =~ s/([^l])<Calocephalus/\1\\l<Calocephalus/)
    {
	$line =~ s/([^l])<Helichrysum/\1\\l<Helichrysum/;  # 2nd typo on line
	if ($showerr)
	{
            print STDERR "$lnum, entry $entry, typo: [corrected!]:\n\t$oline";
	}
    }
    if ($line =~ s/\)\(PV\)/\) \(PV\)/)
    {
	if ($showerr)
	{
            print STDERR "$lnum, entry $entry, space: missing before (PV) [corrected!]:\n\t$oline";
	}
    }
    if ($line eq "\\me \n")
    {
	$tline = <INPUT>;
	if ($tline =~ /^\\/ && $showerr)
	{
	    print STDERR "$lnum, entry $entry, me: empty me line!:\n\t$oline";
	    $lnum++;
	    print STDERR "$lnum, entry $entry, me: this line discarded [bad attempt to fix previous error:\n\t$tline";
	}
	else
	{
	    if ($showerr)
	    {
	        print STDERR "$lnum, entry $entry, me: bogus newline in middle of line:\n\t$oline";
		$lnum++;
	    }
	    chop($line);
	    if ($tline eq " (N) (PV): (Wi,Y)\n")
	    {
		$line = $line . "ngangkarra" . $tline;
	    }
	    else
	    {
		$line = $line . $tline;
	    }
	}
    }
    # charset
    if ($line !~ /^[ !-~“”\pL\pP\pM\pS\pN]*$/ && $showerr)
    {
        print STDERR "$lnum, entry $entry, warning: Line contains character that is not printable:\n\t$oline";
    }
    $line =~ s/\xC9/.../g;
    $line =~ s/\x87/./g;
    $line =~ s/\x88/./g;
    $line =~ s/[\x02\x05]//g;
    # latin angle brackets first recode
    $line =~ s/\\l<([^>]*)>/\{LATIN\}\1\{\/LATIN\}/g;
    $line =~ s/\@l<([^>]*)>/\{LATIN\}\1\{\/LATIN\}/g;
    $line =~ s/\#j<([^>]*)>/\{BOLD\}\1\{\/BOLD\}/g;
    if ($line =~ /^\\wed? /)
    {
	$line =~ s/<([^>]+)>/\{ENGLISH\}\1\{\/ENGLISH\}/g;
    }

    # get rid of ampersands in source before we introduce some
    $line =~ s/&/&amp;/g;
    # other language (warlpiri<->english) cite in angle brackets 
    # - must be before introduce SGML brackets!
    if ($line !~ /^\\lato? / && $line =~ /<[-=A-Za-z .,!?\/()*#'+"\{\}]+>/)
    {
        if ($line =~ /^\\cmp /)
        {
            $line =~ s/<([^>]*)>/\{BOLD\}\1\{\/BOLD\}/g;
        }
	elsif ($showerr) # ie second pass
	{
	    &putinct();
	}
	else
	{
	    $line =~ s/<([-=A-Za-z .,!\/()*#'+"]+)>/<CT>\1<\/CT>/g;
	}
    }
    # derives from << and other case of < from:
    $line =~ s/<</&lt;&lt;/g;
    $line =~ s/<([^C\/])/&lt;\1/g;
    if ($line =~ /[^T"]>/ && $showerr)
    {
        if ($line =~ /^\\lato? /)
        {
	    $line =~ s/>/&gt;/g;
        }
	else
        {
            print STDERR "$lnum, entry $entry, >: Bad occurrence of >:\n\t$oline\t$line";
        }
    }
    # latin angle brackets second recode
    $line =~ s/{(\/?LATIN)}/<\1>/g;
    $line =~ s/{(\/?BOLD)}/<\1>/g;
    $line =~ s/{(\/?ENGLISH)}/<\1>/g;
    # sources in square brackets
    # sometimes the source has an extra < in it which has now become &lt;
    # I presume this is an error and we blow it away.
    $line =~ s/\\\[(?:&lt;|<)?([^<\]]+)\]/<SRC>\1<\/SRC>/g;
    # fix wonky sense nums
    if (($line =~ s/([a-z]) ?\(\*([#1-9])\*?\)/\1\*\2\*/g ||
	 $line =~ s/\*#\*#/\*#\*/g) && $showerr)
    {
        print STDERR "$lnum, entry $entry, hnum: Wonky homophone number [fixed!]:\n\t$oline";
    }
    if ($line =~ /^\\(?:gl|glo|rv) /)
    {
	# replace ^ in words for finder list.
        # TODO: Currently just delete the improved finder list entries, but obviously eventually we should keep them!
        $line =~ s/\^\[[^\]]+\]//g;
        if ( ! $kevinformat)
        {
            $line =~ s/\^([-a-zA-Z'"()]+)/<FL>\1<\/FL>/g;
        }
        # remove remaining or all ^ characters
        $line =~ s/\^//g;
        # remove remaining @ characters in gloss lines
        $line =~ s/^(\\(?:glo?|rv) .*[a-z])@/\1/;
    }
}


sub parseentryline
# this mainly uses local variables, and returns a list of them for further
# processing.  However $entry is set as a global variable, so that all 
# error reports automatically refer to the right word.

{
    local($etype) = shift(@_);	# me or sse or ...
    local($line) = shift(@_);
    local($hw) = "";
    local($hnum);
    local($stuff1);
    local($stuff2);
    local($pos);
    local($pos2);
    local($source);
    local($source2);
    local($remarks);
    local($deriv);
    local($crit);
    local($dialect);

    if ($line !~ /:/ && $etype ne "se")
    {
	print STDERR "$lnum, entry $entry, $etype: missing colon (:) between POS and other stuff [attempting to fix]:\n\t$oline";
	if ($line =~ /\)/)
	{
	    $line =~ s/^([^)]*\))/\1:/;
	}
	else
	{
	    $line =~ s/$/:/;
	}
    }
    if ($line =~ s/\\eme$//)
    {
	print STDERR "$lnum, entry $entry, $etype: erroneous \\eme at end of line [deleted]:\n\t$oline";
    }
    if ($line =~ s/(\*[0-9#]+\*)(\([A-Z])/\1 \2/)
    {
	print STDERR "$lnum, entry $entry, $etype: missing space between headword and POS [corrected!]:\n\t$oline";
    }
    if ($line =~ /^\\${etype} +([-=a-zA-Z()\[\]]+(?: +[A-Z)-]*[-=a-z()]+)*)( *\*[0-9#]+\*)? +(.*)$/)
    {
	$hw=$1;
	if ($etype ne "se")
	{
	    $entry = $hw;	# record entry for errors in global variable
	}
	$hnum=$2;
	$rest=$3;
	if ($rest =~ /^(\(.*\))?: *(.*)$/)
	{
	    $stuff1=$1;
	    $stuff2=$2;
	}
	elsif ($rest =~ /^([A-Z-]+): *(.*)$/)
	{
	    $stuff1=$1;
	    $stuff2=$2;
	}
	elsif ($rest =~ /^([A-Z-]+):?$/)
	{
	    $stuff1="($1)";
	}
	else
	{
	    $stuff1="";
	    $stuff2="";
	    print STDERR "$lnum, entry $entry, $etype: Couldn't handle post headword stuff:\n\t$oline";
	}
	if ($stuff1 =~ /\(([^)]+)\) *(\([^)]+\))?/)
	{
	    $pos = $1;
	    $pos2 = $2;
	    if ($pos2 =~ /\(([^)]+)\)/)
	    {
		$pos2 = $1;
	    }
	}
	elsif ($stuff1 ne "")
	{
	    print STDERR "$lnum, entry $entry, $etype: Couldn't handle pre-colon POS stuff:\n\t$oline";
	}
	$stuff2 = &trimwhite($stuff2);
	$source = "";
	if ($stuff2 =~ /^(.*)(<SRC>.*<\/SRC>)$/)
	{
	    $stuff2 = $1;
	    $source = $2;
	}
	elsif ($stuff2 =~ /^(<SRC>.*<\/SRC>)(.*)$/)
	{
	    $stuff2 = $2;
	    $source = $1;
	}
	$source2 = "";
	if ($stuff2 =~ /^(.*)(<SRC>.*<\/SRC>) *$/)
	{
	    $stuff2 = $1;
	    $source2 = $2;
	}
	$remarks = "";
	if ($stuff2 =~ /^([^{]*)(\{.+\}) *$/)
	{
	    $stuff2 = $1;
	    $remarks = $2;
	}
	$deriv = "";
	# print STDERR "####b stuff2=$stuff2\n";
	if ($stuff2 =~ /^(.*)\([Ll]it\. +([^)]*)\)(.*)$/)
	{
	    $deriv = $2;
	    $stuff2 = "$1$3";
	}
	# print STDERR "####a stuff2=$stuff2 deriv=$deriv\n";
	$crit = "";
	if ($stuff2 =~ /^(.*[^A-Z])?([A-Z]+:) *$/)
	{
	    $crit = $2;
	    $stuff2 = $1;
	}
	$stuff2 = &trimwhite($stuff2);
	if ($stuff2 =~ /^((\([^)]+\) *)*)$/)
	{
	    $dialect = $1;
	    if ($dialect =~ /^\(([^)])\)$/)
	    {
		$dialect = $1;
	    }
	}
	else
	{
	    print STDERR "$lnum, entry $entry, $etype: Couldn't handle post-POS part -- stuff2 is |$stuff2|:\n\t$oline";
	}
    }
    else
    {
	print STDERR "$lnum, entry $entry, $etype: Couldn't handle:\n\t$oline";
    }
    ($hw, $hnum, $pos, $pos2, $source, $source2, $remarks, $deriv, $crit, $dialect);
}


sub entereasyhw
{
    local($word) = shift(@_);
    local($easyhw);

    $easyhw = $word;
    $easyhw =~ tr/-\(\)= //d;
    # print STDERR "### For $hw, easy is $easyhw\n";
    # take first one in case multiple matches (a good heuristic???)
    if ($easyspell{$easyhw} eq "")
    {
	$easyspell{$easyhw} = $word;
    }
    $easyhw = $word;
    if ($easyhw =~ s/\([a-z]+\)$//)
    {
	# enter another one without the bracketed ending.
	$easyhw =~ tr/-\(\)= //d;
	# print STDERR "### For $hw, easy is also $easyhw\n";
	if ($easyspell{$easyhw} eq "")
	{
	    $easyspell{$easyhw} = $word;
	}
    }
    if ($easyhw =~ /[A-Z]/)
    {
	# enter another one that is all lowercase
	$easyhw =~ tr/A-Z/a-z/;
	# print STDERR "### For $hw, easy is also $easyhw\n";
	if ($easyspell{$easyhw} eq "")
	{
	    $easyspell{$easyhw} = $word;
	}
    }
}

#----- build hnumcnts pass

sub buildhnumcnts
{
    local($file) = shift(@_);

    open(INPUT, $file) || die "Couldn't open $file.\n";

    while ($line = <INPUT>)
    {
	&fixupline(0);

	# \me Main entry lines
	if ($line =~ /^\\me /)
	{
	    if ($line =~ /^\\me +([-=a-zA-Z()]+ ?[-=a-z()]+)[ *]/)
	    {
		$hw=$1;
		if ($hnumcnt{$hw})
		{
		    $truehnum = $hnumcnt{$hw} + 1;
		}
		else
		{
		    $truehnum = 1;
		}
		$hnumcnt{$hw} = $truehnum;
	    }
	    else
	    {
		print STDERR "buildhnumcnts: Shouldn't happen.  Couldn't handle:\n\t$line";
	    }
	}
	elsif ($line =~ /^\\sse/)
	{
	    if ($line =~ /^\\sse *<CT>/)
	    {
		$line =~ s/<\/?CT>//g;
	    }
#	    if ($line =~ /^\\sse +([-=a-zA-Z\(\)\[\]]+ ?[-=A-Za-z()]+) */)
#           if ($line =~ /^\\sse +([-=a-zA-Z()]+ ?[-=a-z()]+)[ *]/)
            if ($line =~ /^\\sse +([-=a-zA-Z()\[\]]+ ?[A-Z)-]*[-=a-z()]+)[ *]/)
	    {
		$hw=$1;
		if ($hnumcnt{$hw})
		{
		    $truehnum = $hnumcnt{$hw} + 1;
		}
		else
		{
		    $truehnum = 1;
		}
		$hnumcnt{$hw} = $truehnum;
	    }
	    else
	    {
		print STDERR "buildhnumcnts: Shouldn't happen.  Couldn't handle:\n\t$line";
	    }
	}
    }
}

close(INPUT);



# --------------- Stuff for semantic domains for Katrina -------------

sub semdomains
{
    &buildhnumcnts($ARGV[0]);

    open(INPUT, $ARGV[0]) || die "Couldn't open $ARGV[0]\n";

    while ($line = <INPUT>)
    {
	&fixupline(0);

	# \me Main entry lines
	if ($line =~ /^\\me +([-=a-zA-Z()]+ ?[-=a-z()]+)[ *]/)
	{
	    $hw=$1;
	    if ($hnummcnt{$hw})
	    {
		$truehnum = $hnummcnt{$hw} + 1;
	    }
	    else
	    {
		$truehnum = 1;
	    }
	    $hnummcnt{$hw} = $truehnum;
	}
	elsif ($line =~ /^\\sse/)
	{
	    if ($line =~ /^\\sse *<CT>/)
	    {
		$line =~ s/<\/?CT>//g;
	    }
	    if ($line =~ /^\\sse +([-=a-zA-Z()]+ ?[A-Z)-]*[-=a-z()]+)( *\*[0-9#]+\*)? /)
	    {
		$hw=$1;
		if ($hnummcnt{$hw})
		{
		    $truehnum = $hnummcnt{$hw} + 1;
		}
		else
		{
		    $truehnum = 1;
		}
		$hnummcnt{$hw} = $truehnum;
	    }
	}
	elsif ($line =~ /^\\dm /)
	{
	    $string = &standardhandling($line, "dm");
	    print "$hw: ";
	    if ($hnumcnt{$hw} > 1)
	    {
		print "$truehnum: ";
	    }
	    else
	    {
		print ": ";
	    }
	    print "$string\n";
	}
    }
    close(INPUT);
}

# Changes cited words in angle brackets into CT items
sub putinct
{
    # uses $line as global variable; substitutes in place
    # this doesn't yet verify sense numbers, but all currently blank
    local($word);
    local($hnum);
    local($attrs) = "";

    while ($line =~ /<([-=ABD-Za-z .,!?\/()*#'+"\{\}]+)>/)
    {
        # print STDERR "PUTINCT: line is $line\n";
        # do one at a time
        if ($line =~ /<([-=ABD-Za-z .,!?\/()*#'+"\{\}]+)>\*([#1-9])\*(%[#0-9]%)?/)
        {
	    ($word, $hnum) = verifyword($1, $2, 0);
        }
        else 
        {
	    $line =~ /<([-=ABD-Za-z .,!?\/()*#'+"\{\}]+)>/;
	    ($word, $hnum) = verifyword($1, 0, 0);
        }
        if ($word)
        {
	    $attrs = " HENTRY=\"$word\"";
        }
        if ($kevinformat)
        {
	    # make sure there is an hnum iff appropriate
	    if ($word ne "?" && $hnumcnt{$word} > 1)
	    {
	        $attrs .= " HNUM=\"$hnum\"";
	    }
        }
        elsif ($hnum)
        {
	    $attrs .= " HNUM=\"$hnum\"";
        }
        # if ($snum)
        # {
        #	print " SNUM=\"$snum\"";
        # }
        $line =~ s/<([-=ABD-Za-z .,!?\/()*#'+"\{\}]+)>(\*[#1-9]\*)?(%[#0-9]%)?/<CT${attrs}>\1<\/CT>/;
    }
}


sub verifyword
# this sees whether a word and a certain sense are known

{
    local($str) = shift(@_);	# word as found in reference
    local($hnum) = shift(@_);	# hnum as found in reference
    local($showerrs) = shift(@_);	# 1 = showerrs, 0 = don't
    local($verhw);
    local($easyhw);
    local($easyhw2);
    local($easyhw3);
    local($easyhw4);
    local($mainhw);
    local($checknum);
    local($found);
    local($keepgoing);
    local($upto);
    local($val);
    # check can be found or warn
    $verhw = $str;
    if ($hnumcnt{$str} eq "")
    {
	# it's not found exactly as headword
	$easyhw = $str;
	$easyhw2 = $str;
	$easyhw =~ tr/-\(\)= //d;
	$easyhw2 =~ s/\([a-z]+\)$//;
	$easyhw2 =~ tr/-\(\)= //d;
	$easyhw3 = $easyhw;
	$easyhw3 =~ tr/A-Z/a-z/;
	# For the case of preverbs listed as full form (\\pvl)
	$mainhw = $hw;
	$mainhw =~ tr/-\(\)= //d;
	$mainhw =~ s/\([a-z]+\)$//;
	$mainhw =~ tr/-\(\)= //d;
	$mainhw =~ tr/A-Z/a-z/;
	$easyhw4 = $easyhw3 . $mainhw;
	# print STDERR "### Made easyhw4 of $easyhw4.\n";

	if ($easyspell{$easyhw} ne "")
	{
	    $verhw = $easyspell{$easyhw};
	}
	elsif ($easyspell{$easyhw2} ne "")
	{
	    $verhw = $easyspell{$easyhw2};
	}
	elsif ($easyspell{$easyhw3} ne "")
	{
	    $verhw = $easyspell{$easyhw3};
	}
	elsif ($easyspell{$easyhw4} ne "")
	{
	    $verhw = $easyspell{$easyhw4};
	}
	else
	{
	    $verhw = "?";
	    if ($showerrs)
	    {
		print STDERR "$lnum, entry $entry, annword: Cross reference to $str could not be resolved:\n\t$oline";
	    }
	}
    }	

    # sanity check any assigned hnum
    if ($verhw ne "?" && $hnum =~ /^[0-9]+$/)
    {
	if ($hnum > $hnumcnt{$verhw})
	{
	    print STDERR "$lnum, entry $entry, annword: Homonym number $hnum for cross reference to $str is too big:\n\t$oline";
	    $hnum = "#";
	}
    }
    if ($verhw ne "?" && ($hnum eq "#" ||
		          ($kevinformat && $hnumcnt{$verhw} > 1)))
    {
	if (! $hnum)
	{
	    $hnum = "#";
	}
	if ($hnum !~ /[0-9]+/)
	{
	    $hnum = "#";
	    # we attempt to resolve it using xrefs hash
	    $checknum = 1;
	    $upto = $hnumcnt{$verhw};
	    $found = 0;
	    $keepgoing = 1;
	    while ($keepgoing)
	    {
		$key = "$verhw/$checknum";
		$val = $xrefs{$key};
		# print STDERR "!!! Trying key $key for $hw, val is:\n $val\n";
		if ($val)
		{
		    $temp = $hw;
		    $temp =~ s/\(/\\(/g;
		    $temp =~ s/\)/\\)/g;
		    $temp2 = $hw;
		    $temp2 =~ tr/-\(\)= //d;
		    if ($val =~ $temp || $val =~ $temp2)
		    {
			$found = 1;
			$keepgoing = 0;
			# print STDERR "! Found.\n";
		    }
		    else
		    {
			$checknum++;
			# print STDERR "! Not found.\n";
		    }
		}
		elsif ($checknum = $upto)
		{
		    $keepgoing = 0;
		}
		else
		{
		    $checknum++;
		}
	    }
	    # final check: see if it is a CT about the current word...
	    if ( ! $found && $verhw eq $entry )
	    {
		$hnum = $truehnum;
	    }
	    if ($found)
	    {
		if ($showerrs)
		{
		    print STDERR "$lnum, entry $entry, annword: $str homophone num of # corrected to $checknum:\n\t$oline";
		}
		$hnum = $checknum;
	    }
	}
    }
    ($verhw, $hnum);
}
