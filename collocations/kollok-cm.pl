#!/usr/local/bin/perl 

# kevin's code depended on using extended bigram counts to get unigram counts.
# but that's wrong: to be or not to be
# explicitly store and write unigram counts

# kollok.pl records the collocations that occur in a file
# requires all words to be in paragraphs separated by \n
# ?? or should the separator be '.' ie treat sentences as different
# entities. would involve setting the $/ - field input separator (\n by default)

# this prints a formatted table of results to STDOUT for verifying/testing the 
# collocation algorithms 

$margin = 6;            #the amount of words on considered on either side
			# was 4
$top_most = 3;          #the top collocations listed for each word (in terms of word occurance)

if($#ARGV <= 0) {
    print "Usage: perl kollok.pl <headword file> <suffix file> <corpus> [option]\n";
    print "       options:      -M - print collocations by Mutual Information\n";
    print "                     -L - print collocations by Log Likelihood\n";
    print "			-C - chris output format\n";
    print "                 <none> - will print no results, just making count.dat and mean.dat\n";
    exit 0;
}

# === file names ===
$hw_file = shift;
$suf_file = shift;
$corp_file = shift;
$opt = shift;

# This variable says whether to record all the ways a stem has been inflected.
# Since it doesn't unique-ify the list, it causes enormous space blowouts on
# a biggish corpus
$DB_STEMS = 0;
# This variable is whether to log stemming
$LOG_STEMS = 0;

$STD_DEV = 0;
$JUST_SUFF = "pure suffix";
$MUTUAL_INFO = 0;
$LOG_LIKELY = 0;
   
if ($opt =~ /M/) {
    $MUTUAL_INFO = 1;
}
if ($opt =~ /L/) {
    $LOG_LIKELY = 1;
}
if ($opt =~ /C/) {
    $CHRIS_FORMAT = 1;
}
if ($opt =~ /D/) {
    $DB_STEMS = 1;
}
if ($opt =~ /S/) {
    $LOG_STEMS = 1;
}


init_collocations();

open(HW_FILE, $hw_file) || die "$0: can't open $hw_file: $!\n";
open(SUF_FILE, $suf_file) || die "$0: can't open $suf_file: $!\n";

# read in the headwords file
# Change: just put in stripped one to unify counts!
while(<HW_FILE>) {
    s/\r//; # try to make robust for PC data files
    s/\n//;
    $word = $_;
    # print "Read in |$word|\n";
    # deal with verbs with a hyphenated suffix: \me wangka-mi (V):
    if ($word =~ /^[-=]/) {
	# ignore it
	# print "Case 0\n";
    }
    elsif ($word =~ /^(.*)-[a-z]{1,3}$/ ) {
        $with_opt = $word;
        $no_opt = $1;
	$with_opt =~ s/-//g;
	$no_opt =~ s/-//g;
        $headwords{$no_opt} = $with_opt;
	$headwords{$with_opt}  = $with_opt;
	# print "Case 1\n";
	# print "Entered as |$no_opt|\n";
	# print "Entered as |$with_opt|\n";
    }
    else
    {
	$word =~ s/-//g;
	# deal with words with optional suffix like "jaal(pa)"
	if ( m/\(.*?\)/ ) {
	    $with_opt = $word;
	    $no_opt = $word;
	    $no_opt =~ s/\(.+?\)//g;
	    $with_opt =~ s/\(//g;
	    $with_opt =~ s/\)//g;
	    $headwords{$no_opt} = $with_opt;
	    $headwords{$with_opt}  = $with_opt;
	    # print "Case 2\n";
	    # print "Entered as |${no_opt}|\n";
	    # print "Entered as |${with_opt}|\n";
	}
	else {
	    $headwords{$word} = $word;
	    # print "Case 3\n";
	    # print "Entered as |${word}|\n";
	}
    }
}
$headwords{$JUST_SUFF} = "x";
$TOTAL_HW = $.;
close(HW_FILE);
print STDERR "$TOTAL_HW headwords read in\n";

# read in suffixes
while(<SUF_FILE>) {
    s/\r//; # try to make robust for PC data files
    s/\n//;
    if( m/^=/ ) {
        $clitic{$_}="z";
    } elsif (m/-/) {
        # deal with affixes like -jarri-mi
        $with_opt = $_;
        $no_opt = $_;
	$with_opt =~ s/-//g;
	if ($no_opt =~ /^-(.+)-/)
	{
	    $no_opt = $1;
	}
        $a_suffix{$no_opt} = "y";
        $a_suffix{$with_opt}  = "y";
    } elsif ( m/\(.*?\)/ ) {
        # deal with words with optional suffix like "jaal(pa)"
        $with_opt = $_;
        $no_opt = $_;
        $no_opt =~ s/\(.+?\)//g;
        $with_opt =~ s/\(//g;
        $with_opt =~ s/\)//g;
        $a_suffix{$no_opt} = "y";
        $a_suffix{$with_opt}  = "y";
    }
    else {
        $a_suffix{$_}="y";
    }
}
$num_suffix = $.;
close(SUF_FILE);
@suffix =  sort { length $b <=> length $a } keys %a_suffix;
print STDERR "$num_suffix suffixes read in\n";

# ?? for reading in previously saved data ??
print STDERR "loading data ... \n";
#                                               load_data();
%instances = ();
%errors = ();
open(ERRORS, ">error.log") || die "$0: can't open error.log: $!\n";
if ($LOG_STEMS) {
	open(STEMS, ">stem.log") || die "$0: can't open stem.log: $!\n";
}

# Reads in corpus
$/ = "";        #this means one (\n separated) parargraph is read in at a time
print STDERR "starting corpus processing\n";
open(CORPUS, $corp_file) || die "$0: can't open $corp_file: $!\n";
$total_words = 0;
while(<CORPUS>) {
    next if(m/^\[.*\]$/);
    next if(m/^\s+$/);                   #in case a blank line gets through eg. \t\t\n
    # MAYBE BAD.  TOOK BACK OUTcm change: allow hyphen in word!
    # But this may be bad as explicit hyphens often show compounding!
    @words = split /[^a-zA-Z]+/, $_;     #$words[n] is the nth word in the paragraph 
    $total_words += $#words + 1;	# index starts at 0, so +1 word!
    # print "Sentence has $#words + 1 words\n";
    for( $i = 0 ; $i <= $#words ; $i++) {
	$word = $words[$i];
        $word =~ s/-//g;
	next if ($word eq "");
         
	$stem = &get_stem($word);
	# print "The stem of $word is $stem.\n";
        $wordstems[$i]= $stem;
    }
    for( $i = 0 ; $i <= $#words ; $i++) {
        $fst = $i;			#- $margin
        # $fst = 0 if $fst < 0;

        $lst = $i + $margin;
        $lst = $#words if $lst > $#words;
        
	$stem = $wordstems[$i];
	next if ($stem eq "" || $stem eq $JUST_SUFF);

	$unicount{$stem} += 1;
        for( $j = $fst ; $j <= $lst ; $j++) {
	    if ($j != $i)
	    {
		# for all but the reflexive case
		$stem2 = $wordstems[$j];

		if (($stem2 eq $JUST_SUFF)||($stem2 eq "")) {
		    # cdm: aren't the next two lines redundant??
		    $lst = $i + $margin;
        	    $lst = $#words if $lst > $#words; 
		    next;  
	        }
# 		if ($stem eq "" || $stem2 eq "") {
# 		    print "Null stem for $words[$i] <- $wordstems[$i] and $words[$j] <- $wordstems[$j]\n";
#		}
		new_collocation($stem, $stem2, ($j-$i) );
	    }
        }
    }
    if(($. % 100) == 0) {
	print STDERR "processed sentence $.\n";
    }
}
close(CORPUS);
if ($LOG_STEMS) {
    close(STEMS);
}
print STDERR "$total_words word corpus read in\n";

init_collocations();	    #now initialise all data structs to delete them

if($STD_DEV) {
    calculate_stats();
    print STDERR "Stats claculated\n";
}

if($MUTUAL_INFO) {
    mutual_info();
} elsif ($LOG_LIKELY) {
    log_likely($total_words);
}

print STDERR "saving data ... \n";
save_data();
print STDERR "$0    complete\n";


# ===== sub-routines ===== 

# init_collocations()
#
sub init_collocations {         
    
    # === globals ===
    %a_suffix = ();
    %headwords = ();
    @suffix = ();
    %clitic = ();
    %stems = ();
    %suffs_used = ();
    @current_suffs; 
}

# get_stem($word) returns stem of word
#
sub get_stem {
    local $word = shift(@_);
    my $stem = "";

    $word = lc $word;
    if (defined $stems{$word} ) {
        $stem = $stems{$word};       
    } else {
	$word2 = "";
	if ($word =~ /u/) {
	    $word2 =~ s/u/i/g;
	} elsif ($word =~ /i/) {
	    $word2 =~ s/i/u/g;
	}
	if ($word2 ne "" && defined $stems{$word2}) {
	    $stem = $stems{$word2};
	} else {
	    @current_suffs = ();
	    $stem = &find_stem($word); 
	    if ( defined $stem ) {
		$stems{$word} = $stem;
		foreach $x (@current_suffs) {
		    push (@{$suffs_used{$word}}, $x);
		}
		print_stems($word, $stem);
	    } else {
		print ERRORS "$word in sentence $. has no stem in headwords\n";
		$stems{$word} = $word;
		$errors{$word} = "";
		$stem = $word;
	    }
	}
    }
    return $stem;
}

# find_stem($word) returns stem of word or undef is not found
#
sub find_stem {
    my ($orig_word) = @_;
    my $stem, $prev;
    local $word;
    local $var_orig;
    my $i=0;
    
#    print "stemming $orig_word\n";
    $var_orig = $orig_word;
    if ($var_orig =~ /i[jklmnprtwy]*$/) {
        $var_orig =~ s/i/u/g;
    }
    if ($var_orig =~ /u[jklmnprtwy]*$/) {
	$var_orig =~ s/u/i/g;
    }
    else {
        $var_orig = "";
    }

    if (defined $headwords{$orig_word})  {
        #print "$word is defined\n";
        return $headwords{$orig_word};
    }
    elsif ($var_orig ne "" && defined $headwords{$var_orig}) {
        return $headwords{$var_orig};
    }
    else {
	for( $i = 0 ; $i <= $#suffix ; $i++) {
	    $word = $orig_word;
            $prev = $word;
            $suff = $suffix[$i];
            if ($prev =~ m/i$/) {
                $suff =~ s/u/i/g;
            }
            elsif ($prev =~ m/u$/) {
                $suff =~ s/i/u/g;
            }
            $word =~ s/$suff$//;
            next if $prev eq $word;
	    if ($LOG_STEMS) {
		print STEMS "$prev <= cut to => $word using $suff\n";
	    }
#	    print "$prev cut to $word using $suff\n";
            push (@current_suffs , $suffix[$i]);
            return $JUST_SUFF if($word eq "");
	    $stem = &find_stem($word);
            if (defined $stem ) {
                if (($suff ne $suffix[$i])&&(!defined $a_suffix{$suff})) {
		    if ($LOG_STEMS) {
			print STEMS "##harmony: $prev <= cut to => $word using $suff from $suffix[$i]\n";
		    }
		}
#		print "$orig_word stemmed to $stem.\n";
		return $stem;
            }
        }
    }
#    print "$orig_word: found bugger all.\n";
    return undef;
}


# new_collocation($subject, $target, $distance)
# uses the global hashes:
# %count & %mean 
#
sub new_collocation {
    my ($subject, $target, $dist) = @_;
    my $temp;
    my $pair;

    #switch words so that the the aplh. less words have collocs for all 
    # other words grtr than them.
    if($subject gt $target) {
	$temp = $target;
	$target = $subject;	
	$subject = $temp;
	$dist *= -1;
    }
    $pair = join ':', $subject, $target;

    if($count{$pair} == undef) {
	$count{$pair} = 1;
	$mean{$pair} = $dist;
        if($STD_DEV) {
            push( @{$instances{$pair}} , $dist);
        }
    }
    else {
        $mean{$pair} = (($count{$pair} * $mean{$pair}) + $dist) / ($count{$pair} + 1);
	$count{$pair} += 1;
        if($STD_DEV) {
	    push( @{$instances{$pair}} , $dist);
	}
    }
}


# calculate_stats()
#
# the mean and count have already been calculated, which leaves the 
# std. dev to be filled in from the array of distances in %instances
#
sub calculate_stats {
    
    while ( ($pair, $value) = each %count) {
        $std_dev{$pair} = 0;
        foreach $v ( @{$instances{$pair}}) {
            $std_dev{$pair} += ( $v - $mean{$pair} )**2;
        }

        if($count{$pair} == 1) {
            $std_dev = 0;
        }
        else {
            $std_dev{$pair} /= ($count{$pair} - 1);
        }
        $std_dev{$pair} **= 0.5;
        #print "Standard deviation: $data->[3]\n";
    }
}

# mutual_info ()
#
sub mutual_info {
    my $max_mut = 0.0;
    
    select((select(STDOUT), $^ = "KOLLOK_TOP", $~ = "KOLLOK")[0]);
    while ( ($pair, $value) = each %count) {
	($w1, $w2) = split /:/, $pair;
        if(defined $errors{$w1}) {
	    $f1 = "*";
	} else { 
            $f1 ="";
	}
	if(defined $errors{$w2}) {
	    $f2 = "*";
	} else {
	    $f2 = "";
	}
        $likely = ($count{$pair}) / (($unicount{$w1}) * ($unicount{$w2}));
        if (( $unicount{$w1} > 3 ) && ( $unicount{$w2} > 3 ) &&
		( $count{$pair} > 1 ) && ($likely > 0.05)) {
		write;
		$max_mut = $likely;
	}
    }
}

# log_likely($total_words_in_corpus)
#
sub log_likely {
    my ($N)= @_;
    my $c1=0.0, $c2=0.0, $c12=0.0, $b=0.0, $c=0.0, $d=0.0;
    my $max_like = 0.0;

    select((select(STDOUT), $^ = "LIKELY_TOP", $~ = "KOLLOK")[0]);
    while ( ($pair, $value) = each %count) {
        ($w1, $w2) = split /:/, $pair;
        if(defined $errors{$w1}) {
            $f1 = "*";
        } else { 
            $f1 ="";
        }
        if(defined $errors{$w2}) {
            $f2 = "*";
        } else {
            $f2 = "";
        }
        $c1 = $unicount{$w1};
        $c2 = $unicount{$w2};
        $c12 = $count{$pair};
        $c12 = $c1 if $c1<$c12;            # because of the case word1 word2 word1      $c1=2 $c2=1 $c12=2
        $c12 = $c2 if $c2<$c12;

        $b = $c1 - $c12;
        $c = $c2 - $c12;
        $d = $N - $c1 - $c2 + $c12;
        
        $likely = 0;
        eval {
            $likely = log( (($c2/$N)**$c12) * ((1 - ($c2/$N))**$b) );
        };
        if ($@) {
            print "error1: b=$b c=$c d=$d c1=$c1 c2=$c2 c12=$c12 N=$N \n";
            print "error1: ".(($c2/$N)**$c12)." * ".((1 - ($c2/$N))**$b)."\n";
            next;
        }

        eval {
            $likely += log( (($c2/$N)**$c) * ((1 - ($c2/$N))**$d) );
        };
        if ($@) {
            print "error2: b=$b c=$c d=$d c1=$c1 c2=$c2 c12=$c12 N=$N \n";
            print "error2: ".(($c2/$N)**$c)." * ".((1 - ($c2/$N))**$d)."\n";
            next;
        }

        eval {
            $likely -= log( (($c12/$c1)**$c12) * ((1 - ($c12/$c1))**$b) );
        };
        if ($@) {
            print "error3: b=$b c=$c d=$d c1=$c1 c2=$c2 c12=$c12 N=$N \n";
            print "error3: ".(($c12/$c1)**$c12)." * ".((1 - ($c12/$c1))**$b)."\n";
            next;
        }

        eval {
            $likely -= log( (($c/($N-$c1))**$c) * ((1 - ($c/($N-$c1)))**$d) );
        };
        if ($@) {
            print "error4: b=$b c=$c d=$d c1=$c1 c2=$c2 c12=$c12 N=$N \n";
            print "error4: ".(($c/($N-$c1))**$c)." * ".((1 - ($c/($N-$c1)))**$d)."\n";
            next;
        }

        $likely *= -2;

        if (( $unicount{$w1} > 3 ) && ( $unicount{$w2} > 3 ) &&
                ( $count{$pair} > 1 ) && ($likely > 10)) {
                write;
                $max_like = $likely;
        }
    }
}


# load_data()
#
sub load_data {
    if( !(-e "count.dat")) {
        return;
    }
    open(COUNT, "count.dat") || die "$0: can't open count.dat: $!\n";
    while (<COUNT>) {
        s/\n//g;
        ($key, $value) = split /#/;
        $count{$key} = $value;
        $total++;
    }
    close(COUNT);
    open(MEAN, "mean.dat") || die "$0: can't open mean.dat: $!\n";
    $check = 0;
    while (<MEAN>) {
        s/\n//g;
        ($key, $value) = split /#/;
        $mean{$key} = $value;
        $check++;
    }
    close(MEAN);
    print STDERR "ERROR: $total count items and only $check mean items\n" if($total != $check);
}

# save_data()
#
sub save_data {
    open(COUNT, ">count.dat") || die "$0: can't open count.dat: $!\n";
    while ( ($pair, $value) = each %count) {
	if ($CHRIS_FORMAT)
	{
	    $pair =~ s/:/ /;
	    print COUNT "$value $pair\n";
	}
	else
	{
            $key = join '#', $pair, $value;
            print COUNT "$key\n";
        }
    }
    close(COUNT);
    open(UNICOUNT, ">unicount.dat") || die "$0: can't open unicount.dat: $!\n";
    while ( ($word, $value) = each %unicount) {
	if ($CHRIS_FORMAT)
	{
	    print UNICOUNT "$value $word\n";
	}
	else
	{
            $key = join '#', $word, $value;
            print UNICOUNT "$key\n";
        }
    }
    close(UNICOUNT);
    open(MEAN, ">mean.dat") || die "$0: can't open mean.dat: $!\n";
    while ( ($pair, $value) = each %mean) {
        $key = join '#', $pair, $value;
        print MEAN "$key\n";
    }
    close(MEAN);
}

# print_stems($word, $stem);
# 
sub print_stems {
    my ($word, $stem) = @_;

    if(($DB_STEMS == 0)||($#{$suffs_used{$word}} < 1)) {
	return;
    }
    print STEMS "$word <=cut to=>  $stem \(";
    foreach $x (@{$suffs_used{$word}}) {
        print STEMS $x, " ";
    }
    print STEMS "\) \n";
}



# ===== formats  =======

format LIKELY_TOP = 
_______________ Collocations __________________________________________________
    WORD 1                      WORD 2                Occurances   Dist.  LLkly. 
                                                    Pair  W1   W2 
_______________________________________________________________________________
.

format KOLLOK_TOP = 
_______________ Collocations __________________________________________________
    WORD 1  			WORD 2  	      Occurances   Dist.  MInf. 
						    Pair  W1   W2 
_______________________________________________________________________________
.


format KOLLOK = 
@|@<<<<<<<<<<<<<<<<<<<<<< @|@<<<<<<<<<<<<<<<<<<<<<< @||  @||  @||  @|||   @|||| 
$f1, $w1,		$f2, $w2,	$count{$pair}, $count{$w1_key}, $count{$w2_key}, $mean{$pair}, $likely
.

    

