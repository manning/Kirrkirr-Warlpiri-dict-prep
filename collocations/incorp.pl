#!/gnu/usr/bin/perl

#incorporates the collocation data into the XML dictionary by
# 1: adding the <FREQ> tag to signify the frequency of the entry's occurance
# 2: adding the <COLLOC> tag to signify collocates

$dict = shift;
$new = shift;

$total = 0;
load_data();
print STDERR "data loaded\n";
open(ERROR, ">error.log") || die "$0: can't open error.log: $!\n";
print STDERR "writting new XML dictionary\n";
$mean = ();
open(FILE, $dict) || die "$0: can't open $dict: $!\n";
open(NEW, ">$new") || die "$0: can't open $new: $!\n";
$inform = 0;
while(<FILE>) {
    print NEW $_;
    if(m/^\<ENTRY/) {
	$word = $_;
	$word =~ s/-//g;
	$word =~ s/\<.+?\>//g;
	$word =~ s/\n//g;
        if ( $word =~ m/\(.*?\)/ ) {
            $with_opt = $word;
            $no_opt = $word;
            $no_opt =~ s/\(.+?\)//g;
            $with_opt =~ s/\(//g;
            $with_opt =~ s/\)//g;
	    new_opt_data($with_opt, $no_opt);
	}
	else {
	    new_data($word);
	}
        $inform++;
        if(($inform % 1000)==0) {
            print "$inform entries processed\n";
        }
    }          	
}
close(NEW);
close(FILE);
close(ERROR);

# load_data()
#
sub load_data {
    open(COUNT, "count.dat") || die "$0: can't open count.dat: $!\n";
    while (<COUNT>) {
        s/\n//g;
        ($key, $value) = split /#/;
        $count{$key} = $value;
        $total++;
    }
    close(COUNT);
    open(COLL, "coll.dat") || die "$0: can't open coll.dat: $!\n";
    $check = 0;
    while (<COLL>) {
        s/\n//g;
        ($w1, $w2, $mean) = split /#/;
        $word_pairs{$w1}{$w2} = $mean;
        $word_pairs{$w2}{$w1} = -1 * $mean;
    }
    close(COLL);
}


#new_data()
sub new_data {
    my ($word) = @_;
    $w_key = join ':', $word, $word;
    if(defined  $count{$w_key}) {
        print NEW "\<FREQ\>$count{$w_key}\<\/FREQ\>\n";
	#if(defined  $word_pairs{$word}) {
        if(0) {
	    print NEW "\<COLLOC\>";
            while ( ($word2, $value2) = each %{$word_pairs{$word}} ) {
        	$data = $word_pairs{$word}{$word2};
		print NEW "\<COLLI dist=\"$data\"\>$word2\<\/COLLI\>";
            }
	    print NEW "\<\/COLLOC\>\n";
        }
        else {
            print ERROR "$word has no collocations\n";
        }
    }
    else {
        print ERROR "$w_key has no frequency\n";
        print NEW "\<FREQ\>0\<\/FREQ\>\n";
    }
}

#new_data()
sub new_opt_data {
    my ($with, $without) = @_;
    $w_key = join ':', $with, $with;
    $o_key = join ':', $without, $without;
    if((defined  $count{$w_key})||(defined  $count{$o_key})) {
        print NEW "\<FREQ\>",($count{$w_key}+$count{$o_key}),"\<\/FREQ\>\n";
        #if((defined  $word_pairs{$with})||(defined  $word_pairs{$without})) {
        if(0) {
            print NEW "\<COLLOC\>";
            while ( ($word2, $value2) = each %{$word_pairs{$with}} ) {
                $data = $word_pairs{$with}{$word2};
                print NEW "\<COLLI dist=\"$data\"\>$word2\<\/COLLI\>";
            }
            while ( ($word2, $value2) = each %{$word_pairs{$without}} ) {
                $data = $word_pairs{$without}{$word2};
                print NEW "\<COLLI dist=\"$data\"\>$word2\<\/COLLI\>";
            }
            print NEW "\<\/COLLOC\>\n";
        }
        else {
            print ERROR "$with and $without have no collocations\n";
        }
    }
    else {
        print ERROR "$w_key and $o_key have no frequency\n";
        print NEW "\<FREQ\>0\<\/FREQ\>\n";
    }
}

