#!/usr/local/bin/perl

# runs as a filter.  Warlpiri <-> XML
# A complicated regexp matching hack.

# Christopher Manning .. July 1998
# updated .. August 1998.  Growing subroutines.
# 8 aug 98 - now good dialect handling
# 9 aug 98 - more general
# 5oct98 - rewritten to be stack based; fix subentries, etc.
# nov 98 - some more fixes and extensions

# state variables
$entry = "[Beginning]";
$lnum = 0;
@instack = ();

# dictionary header - now done in script 
# print "<?XML version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
# print "<DICTIONARY>\n";

while ($line = <>)
{
    $lnum++;
    # remember the uncorrupted line for error reports
    $oline = $line;

    # global changes
    # one off typo fixes
    if ($line =~ s/<Japara-kanyi</<Japara-kanyi>/ ||
	$line =~ s/<warukupalupalu</<warukupalupalu>/)
    {
        print STDERR "$lnum, entry $entry, typo: [corrected!]:\n\t$oline";
    }
    if ($line eq "\\me \n")
    {
	$tline = <>;
	if ($tline =~ /^\\/)
	{
	    print STDERR "$lnum, entry $entry, me: empty me line!:\n\t$oline";
	    $lnum++;
	    print STDERR "$lnum, entry $entry, me: this line discarded [bad attempt to fix previous error:\n\t$tline";
	}
	else
	{
	    print STDERR "$lnum, entry $entry, me: bogus newline in middle of line:\n\t$oline";
	    $lnum++;
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
    if ($line =~ /[\x7F-\xFF]/)
    {
        print STDERR "$lnum, entry $entry, warning: Line contains non-ASCII character:\n\t$oline";
    }
    $line =~ s/\xC9/.../g;
    $line =~ s/\x87/./g;
    $line =~ s/\x88/./g;
    # latin angle brackets first recode
    $line =~ s/\\l<([^>]*)>/\{LATIN\}\1\{\/LATIN\}/g;
    # get rid of ampersands in source before we introduce some
    $line =~ s/&/&amp;/g;
    # other language (warlpiri<->english) cite in angle brackets 
    # - must be before introduce SGML brackets!
    $line =~ s/<([-A-za-z .,!\/()*#'+"]+)>/<CT>\1<\/CT>/g;
    # derives from << and other case of < from:
    $line =~ s/<</&lt;&lt;/g;
    $line =~ s/<([^C\/])/&lt;\1/g;
    if ($line =~ /[^T]>/)
    {
        print STDERR "$lnum, entry $entry, >: Bad occurrence of >:\n\t$oline";
    }
    # latin angle brackets second recode
    $line =~ s/{(\/?LATIN)}/<\1>/g;
    # sources in square brackets
    # sometimes the source has an extra < in it which has now become &lt;
    # I presume this is an error and we blow it away.
    $line =~ s/\\\[(&lt;|<)?([^<\]]+)\]/<SRC>\2<\/SRC>/g;
    # replace ^ in words for finder list.
    $line =~ s/\^([-a-zA-Z'"()]+)/<FL>\1<\/FL>/g;
    # remove remaining ^ (only a little bit bad...)
    $line =~ s/\^//g;

#    if ($line =~ /^\\([a-z]+)/)
#    {
#	print STDERR "Line $lnum is $1, stack is @instack\n";
#    }

    # \me Main entry lines
    if ($line =~ /^\\me/)
    {
	&closeallopen;
	push(@instack, "pme");	# the pseudo me that continues past \eme
	push(@instack, "me");
	if ($line !~ /:/)
	{
	    print STDERR "$lnum, entry $entry, me: missing colon (:) separator between POS and other stuff: [attempting to fix]\n\t$oline";
	    if ($line =~ /\)/)
	    {
		$line =~ s/^([^)]*\))/\1:/;
	    }
	    else
	    {
		$line =~ s/^([^ ]) /\1: /;
	    }
	}
	if ($line =~ /^\\me +([-=a-zA-Z()]+) *(\*[0-9#]+\*)? *(\(.*\)) *: *(.*)$/)
	{
	    $hw=$1;
	    $entry = $hw;	# record entry for errors
	    $hnum=$2;
	    $stuff1=$3;
	    $stuff2=$4;
	    if ($stuff1 =~ /\(([^)]+)\) *(\([^)]+\))?/)
	    {
		$pos = $1;
		$pos2 = $2;
		if ($pos2 =~ /\(([^)]+)\)/)
		{
		    $pos2 = $1;
		}
	    }
	    else
	    {
	        print STDERR "$lnum, entry $entry, me: Couldn't handle: [omitted!]\n\t$oline";
	    }
	    $deriv = "";
	    $dialect = "";
	    $remarks = "";
	    $source = "";
	    $stuff2 = &trimwhite($stuff2);
	    while ($stuff2 ne "")
	    {
		if ($stuff2 =~ /^[ \t]*(\([^)]+\))(.*)$/)
		{
		    $stuff2 = $2;
		    $piece = $1;
		    if ($piece =~ /\([Ll]it\. ([^)]+)\)/)
		    {
			$deriv = $1;
		    }
		    elsif ($piece =~ /\(([^)]+)\)/)
		    {
		        $dialect = $1;
		    }
		    else
		    {
	                print STDERR "$lnum, entry $entry, me: Couldn't handle end part of:\n\t$oline";
		    }
		}
		elsif ($stuff2 =~ /^[ \t]*(\{.+\})(.*)$/)
		{
		    $stuff2 = $2;
		    $remarks = $1;
		}
		elsif ($stuff2 =~ /^[ \t]*(<SRC>.*<\/SRC>)(.*)$/)
		{
		    $stuff2 = $2;
		    $source = $1;
		}
		else
		{
		    print STDERR "$lnum, entry $entry, me: Couldn't handle end part of:\n\t$oline";
		    $stuff2 = "";
		}
	        $stuff2 = &trimwhite($stuff2);
	    }
	    if ($hnum ne "")
	    {
	        if ($hnum =~ /\*([0-9#]+)\*/)
	        {
		    $hnum = $1;
	        }
	        print "<ENTRY><HW HNUM=\"$hnum\">$hw</HW>\n";
	    }
	    else
	    {
	        print "<ENTRY><HW>$hw</HW>\n";
	    }
	    print "<POS>$pos</POS>\n";
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
	}
	else
	{
	    print STDERR "$lnum, entry $entry, me: Couldn't handle:\n\t$oline";
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
    elsif ($line =~ /^\\(cf|alt|syn|ant|pvl|see|xme)/)
    {
	$what = $1;
	$uwhat = $what;
	$uwhat =~ tr/a-z/A-Z/;
	if ($what eq "see")
	{
	    print STDERR "$lnum, entry $entry, cf: see used instead of cf [corrected!]:\n\t$oline";
	    $uwhat = "CF";
	}
	$string = &standardhandling($line, $what);
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
		# print "</SENSE>\n"; - should do heuristicclose??
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
    # \sse lines -- should use subroutine to share with me
    elsif ($line =~ /^\\sse/)
    {
	if ($line =~ /^\\sse *<CT>/)
	{
	    print STDERR "$lnum, entry $entry, sse: Shouldn't have Warlpiri in brackets on sse line [corrected!]:\n\t$oline";
	    $line =~ s/<\/?CT>//g;
	}
	if ($line =~ /^\\sse +([-a-zA-Z()]+) *(\*[0-9#]+\*)? +([^:]+): *(.*)$/)
	{
	    &closemostopen;
	    push(@instack, "psse");
	    push(@instack, "sse");
	    $hw=$1;
	    $entry = $hw;	# record entry for errors
	    $hnum=$2;
	    $stuff1=$3;
	    $stuff2=$4;
	    if ($stuff1 =~ /\(([^)]+)\) *(\([^)]+\))?/)
	    {
		$pos = $1;
		$pos2 = $2;
		if ($pos2 =~ /\(([^)]+)\)/)
		{
		    $pos2 = $1;
		}
	    }
	    else
	    {
	        print STDERR "$lnum, entry $entry, sse: Couldn't handle:\n\t$oline";
	    }
	    $source = "";
	    if ($stuff2 =~ /^(.*)(<SRC>.*<\/SRC>) *$/)
	    {
		$stuff2 = $1;
		$source = $2;
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
	    if ($stuff2 =~ /^(.*)\([Ll]it\. +([^)]*)\):? *$/)
	    {
		$deriv = $2;
		$stuff2 = $1;
	    }
	    $crit = "";
	    if ($stuff2 =~ /^(.*[^A-Z])?([A-Z]+:) *$/)
	    {
		$crit = $2;
		$stuff2 = $1;
	    }
	    if ($stuff2 =~ /^ *(\([^)]+\))? *$/)
	    {
		$dialect = $1;
		if ($dialect =~ /\(([^)])\)/)
		{
		    $dialect = $1;
		}
	    }
	    else
	    {
		print STDERR "$lnum, entry $entry, sse: Couldn't handle post-POS part -- stuff2 is |$stuff2|:\n\t$oline";
	    }
	    if ($hnum ne "")
	    {
	        if ($hnum =~ /\*([0-9#]+)\*/)
	        {
		    $hnum = $1;
	        }
	        print "<SUBENTRY><HW HNUM=\"$hnum\" TYPE=\"SUB\">$hw</HW>\n";
	    }
	    else
	    {
	        print "<SUBENTRY><HW TYPE=\"SUB\">$hw</HW>\n";
	    }
	    print "<POS>$pos</POS>\n";
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
	}
	else
	{
	    print STDERR "$lnum, entry $entry, sse: Couldn't handle:\n\t$oline";
	}
    }
    elsif ($line =~ /^\\esse/)
    {
	&endnotrail($line);
	&heuristicclose("sse", "sse");
    }
    elsif ($line =~ /^\\(lat|rul|refa|ref|cmp|def|cm|csl|gl) /)
    {
	$what = $1;
	$uwhat = $what;
	$uwhat =~ tr/a-z/A-Z/;
	$string = &standardhandling($line, $what);
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
	    print "<ET>$1</ET>";
	    &heuristicclose("we", "Warlpiri example");
	}
	elsif ($line =~ /^\\et +(.*)\\ewed? *$/)
	{
	    print "<ET>$1</ET>";
	    &heuristicclose("we", "Warlpiri example");
	}
	elsif ($line =~ /^\\et +(.*)\\eeg$/)
	{
	    print "<ET>$1</ET>";
	    &heuristicclose("we", "Warlpiri example");
	    print STDERR "$lnum, entry $entry, et: missing \\ewe(d) at end of line [corrected!]\n\t$oline";
	    &heuristicclose("eg", "examples");
	}
	elsif ($line =~ /^\\et +(.*)$/)
	{
	    print "<ET>$1</ET>\n";
	}
	elsif ($line =~ /^\\et *$/)
	{
	    print STDERR "$lnum, entry $entry, et: malformed (no?) translation:\n\t$oline";
	    print "<ET></ET>\n";
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
	$string = &standardhandling($line, "dm");
	if ($string ne "")
	{
	    &printdomain($string);
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
# print "</DICTIONARY>\n";


sub seealsodecode 
# this routine depends on splitting on /, / being adequate ...
# we try to fix any wrong ones given in sources
{
    local($str) = shift(@_);
    local($tag) = shift(@_);

    print "<$tag>";
    # do it twice, in case two commas (there are once!)
    $str =~ s/(<SRC>[^<]*,) +([^ ][^<]*<\/SRC>)/\1\2/;
    $str =~ s/(<SRC>[^<]*,) +([^ ][^<]*<\/SRC>)/\1\2/;
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
    local($str) = shift(@_);
    local($tag) = shift(@_);
    local($sense) = 0;
    local($hnum) = 0;
    local($dialect) = "";

    $str = &trimwhite($str);
    if ($str =~ /^(.*[^ ]) +\((.*)\)$/)
    {
	$str = $1;
	$dialect = $2;
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
    print "<${tag}I";
    if ($hnum)
    {
	print " HNUM=\"$hnum\"";
    }
    if ($sense)
    {
	print " SNUM=\"$sense\"";
    }
    print ">$str";
    &printdialects($dialect, 0);
    print "</${tag}I>";
}


sub printdialects
# can have the brackets still around it or not: (La,Y) or just Y
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

	print "<DIALECTS>";
	if ($str =~ /^\((.*)\)$/)
	{
	    $str = $1;
	}
	@fields = split(/, */, $str);
	while ($thing = shift(@fields))
	{
	    print "<DLI>$thing</DLI>";
	    if ($#fields >= 0)
	    {
		print ",";
	    }
	}
	print "</DIALECTS>";
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
    local($str) = shift(@_);
    local($thing);
    local(@fields);

    print "<DOMAIN>";
    $str = &trimwhite($str);
    @fields = split(/: */, $str);
    while ($thing = shift(@fields))
    {
        print "<DMI>$thing</DMI>: ";
    }
    print "</DOMAIN>\n";
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
    local($string) = "";

    if ($str =~ /^\\${tag} +(.*)\\e${tag}$/)
{
    $string = $1;
}
elsif ($str =~ /^\\${tag} +(.*)\\${tag}$/)
{
    print STDERR "$lnum, entry $entry, $tag: \\$tag should be \\e$tag [corrected!]:\n\t$oline";
    $string = $1;
}
elsif ($str =~ /^\\${tag} +(.*)(\\e[a-z]+)$/)
{
    print STDERR "$lnum, entry $entry, $tag: $2 should be \\e$tag [corrected!]:\n\t$oline";
    $string = $1;
}
elsif ($line =~ /^\\${tag} +(.*)$/)
{
    print STDERR "$lnum, entry $entry, $tag: Missing \\e$tag [corrected!]:\n\t$oline";
    $string = $1;
}
else
{
    print STDERR "$lnum, entry $entry, $tag: Couldn't handle:\n\t$oline";
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


sub closeopen
{
    local($item) = shift(@_);
    local($iserror) = shift(@_);

    if ($item eq "pme")
    {
	print "</ENTRY>\n\n";
    }
    elsif ($item eq "psse")
    {
	print "</SUBENTRY>\n";
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

