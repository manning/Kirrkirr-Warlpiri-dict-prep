#!/usr/local/bin/perl

#incorporates the collocation data into the XML dictionary by
# 1: adding the <FREQ> tag to signify the frequency of the entry's occurance
# 2: adding the <COLLOC> tag to signify collocates

$putincolloc = 0;

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
        $word =~ tr/A-Z/a-z/;
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
    open(COUNT, "unicount.dat") || die "$0: can't open count.dat: $!\n";
    while (<COUNT>) {
        s/\n//g;
        ($value, $key) = split;
        $count{$key} = $value;
        $total++;
    }
    close(COUNT);
    if ($putincolloc)
    {
    open(BADWORDS, "badwords.dat") || die "$0: can't open badwords.dat: $!\n";
    while ($key = <BADWORDS>) {
        chop $key;
        $bad{$key} = 1;
    }
    close(BADWORDS);
    open(COLL, "crl-4.loglikely") || die "$0: can't open colloc data: $!\n";
    $check = 0;
    while (<COLL>) {
        s/\n//g;
        ($mean, $w1, $w2) = split;
        $word_pairs{$w1}{$w2} = $mean;
        $word_pairs{$w2}{$w1} = -1 * $mean;
    }
    close(COLL);
    }
}


#new_data()
sub new_data {
    my ($word) = @_;
    if(defined  $count{$word}) {
        print NEW "\<FREQ\>$count{$word}\<\/FREQ\>\n";
        if ($putincolloc) {
	if(defined  $word_pairs{$word}) {
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
    }
    else {
        print ERROR "$word has no frequency\n";
        print NEW "\<FREQ\>0\<\/FREQ\>\n";
    }
}

#new_data()
sub new_opt_data {
    my ($with, $without) = @_;
    if((defined  $count{$with})||(defined  $count{$without})) {
        print NEW "\<FREQ\>",($count{$with}+$count{$without}),"\<\/FREQ\>\n";
        if($putincolloc) {
        if((defined  $word_pairs{$with})||(defined  $word_pairs{$without})) {
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
    }
    else {
        print ERROR "$with and $without have no frequency\n";
        print NEW "\<FREQ\>0\<\/FREQ\>\n";
    }
}

