#!/gnu/usr/bin/perl 

# kollok.pl records the collocations that occur in a file
# requires all words to be in paragraphs separated by \n
# ?? or should the separator be '.' ie treat sentences as different
# entities. would involve setting the $/ - field input separator (\n by default)

# this prints a formatted table of results to STDOUT for verifying/testing the 
# collocation algorithms 

$margin = 4;            #the amount of words on considered on either side
$top_most = 3;          #the top collocations listed for each word (in terms of word occurance)

if($#ARGV <= 0) {
    print "Usage: perl kollok.pl <headword file> <suffix file> <corpus> [option]\n";
    print "       options:      -M - print collocations by Mutual Information\n";
    print "                     -L - print collocations by Log Likelihood\n";
    print "                 <none> - will print no results, just making count.dat and mean.dat\n";
    exit 0;
}

# === file names ===
$hw_file = shift;
$suf_file = shift;
$corp_file = shift;
$opt = shift;

$DB_STEMS = 1;
$STD_DEV = 0;
$JUST_SUFF = "pure suffix";
$MUTUAL_INFO = 0;
$LOG_LIKELY = 0;
   
if($opt =~ m/M/) {
    $MUTUAL_INFO = 1;
} elsif($opt =~ m/L/) {
    $LOG_LIKELY = 1;
}


init_collocations();

open(HW_FILE, $hw_file) || die "$0: can't open $hw_file: $!\n";
open(SUF_FILE, $suf_file) || die "$0: can't open $suf_file: $!\n";
while(<HW_FILE>) {
    s/\n//;
    s/-//g;
    $word = $_;
    if ( m/\(.*?\)/ ) {
        $with_opt = $word;
        $no_opt = $word;
        $no_opt =~ s/\(.+?\)//g;
        $with_opt =~ s/\(//g;
        $with_opt =~ s/\)//g;
        $headwords{$no_opt} = "x";
	$headwords{$with_opt}  = "x";
    }
    else {
        $headwords{$word} = "x";
    }
}
$headwords{$JUST_SUFF} = "x";
$TOTAL_HW = $.;
close(HW_FILE);
print STDERR "Headwords read in\n";
while(<SUF_FILE>) {
    s/\n//;
    s/-//g;
    if( m/^=/ ) {
        $clitic{$_}="z";
    }
    elsif ( m/\(.*?\)/ ) {
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

@suffix =  sort { length $b <=> length $a } keys %a_suffix;
close(SUF_FILE);
print STDERR "Suffixes read in\n";
print STDERR "loading data ... \n";
#                                               load_data();
%instances = ();
%errors = ();
open(ERRORS, ">error.log") || die "$0: can't open error.log: $!\n";
open(STEMS, ">stem.log") || die "$0: can't open stem.log: $!\n";

$/ = "";        #this means one (\n separated) parargraph is read in at a time
print STDERR "loaded data ... starting Corpus processing\n";
open(CORPUS, $corp_file) || die "$0: can't open $corp_file: $!\n";
$total_words = 0;
while(<CORPUS>) {
    next if(m/^\[.*\]$/);
    next if(m/^\s+$/);                   #in case a blank line gets through eg. \t\t\n
    @words = split /[^a-zA-Z]+/, $_;     #$words[n] is the nth word in the paragraph 
    $total_words += $#words;
    for( $i = 0 ; $i <= $#words ; $i++) {
        $fst = $i;			#- $margin
        $fst = 0 if $fst < 0;

        $lst = $i + $margin;
        $lst = $#words if $lst > $#words;
        
        $word = lc $words[$i];
        $word =~ s/-//g;
	next if ($word eq "");
	$stem = get_stem($word);
	next if ($stem eq $JUST_SUFF);

        for( $j = $fst ; $j <= $lst ; $j++) {
            $words[$j] =~ s/-//g;
	    $stem2 = get_stem($words[$j]);

	    if (($stem2 eq $JUST_SUFF)||($words[$j] eq "")) {
		$lst = $i + $margin;
        	$lst = $#words if $lst > $#words; 
		next;  
	    }
	    new_collocation($stem, $stem2, ($j-$i) );
        }
    }
    if(($. % 500) == 0) {
	print STDERR "processed line $.\n";
    }
}
close(CORPUS);
close(STEMS);
print STDERR "Corpus read in\n";

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
    my ($word) = @_;
    my $stem = "";

    $word = lc $word;
    if (! defined $stems{$word} ) {
        @current_suffs = ();
        $stem = find_stem($word); 
	if ( defined $stem ) {
            $stems{$word} = $stem;
            foreach $x (@current_suffs) {
                push (@{$suffs_used{$word}}, $x);
            }
	    print_stems($word, $stem);
        } else {
            print ERRORS "$word: on line $. has no stem in headwords\n";
            $stems{$word} = $word;
	    $errors{$word} = "";
            $stem = $word;
        }
    } else {
        $stem = $stems{$word};       
    }
    return $stem;
}

# find_stem($word) returns stem of word or undef is not found
#
sub find_stem {
    my ($orig_word) = @_;
    my $stem, $word, $prev;
    my $i=0;
    
    if (defined $headwords{$orig_word})  {
        #print "$word is defined\n";
        return $orig_word;
    }
    else {
	for( $i = 0 ; $i <= $#suffix ; $i++) {
	    $word = $orig_word;
            $prev = $word;
            $suff = $suffix[$i];
            if ($prev =~ m/[i]$/) {
                $suff =~ s/u$/i/;
            }
            elsif ($prev =~ m/[u]$/) {
                $suff =~ s/i$/u/;
            }
            $word =~ s/$suff$//;
            next if $prev eq $word;
	    #print "$prev <= cut to => $word using $suff\n";
            push (@current_suffs , $suffix[$i]);
            return $JUST_SUFF if($word eq "");
	    $stem = find_stem($word);
            if (defined $stem ) {
                if (($suff ne $suffix[$i])&&(!defined $a_suffix{$suff})) {
		    print STEMS "##harmony: $prev <= cut to => $word using $suff from $suffix[$i]\n";
		}
		return $stem;
            }
        }
    }
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
        $w1_key = join ':', $w1, $w1;
        $w2_key = join ':', $w2, $w2;
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
        $likely = ($count{$pair}) / (($count{$w1_key}) * ($count{$w2_key}));
        if (( $count{$w1_key} > 3 ) && ( $count{$w2_key} > 3 ) &&
		( $count{$pair} > 1 ) && ($w1 ne $w2) && ($likely > 0.05)) {
		write;
		$max_mut = $likely;
	}
        #print STDERR "processed word $w\n"; 
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
        $w1_key = join ':', $w1, $w1;
        $w2_key = join ':', $w2, $w2;
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
        $c1 = $count{$w1_key};
        $c2 = $count{$w2_key};
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

        if (( $count{$w1_key} > 3 ) && ( $count{$w2_key} > 3 ) &&
                ( $count{$pair} > 1 ) && ($w1 ne $w2) && ($likely > 10)) {
                write;
                $max_like = $likely;
        }
        #print STDERR "processed word $w\n"; 
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
        $key = join '#', $pair, $value;
        print COUNT "$key\n";
    }
    close(COUNT);
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

    

