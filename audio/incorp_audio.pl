#!/usr/bin/perl
##!/usr/local/bin/perl
##!/gnu/usr/bin/perl

if($#ARGV <= 0) {
    print "Usage: perl incorp_audio.pl <xmlfile> <new filename>\n";
    print "     (uses audio.dat for the list of *.au in kirrkirr/audio)\n";
    exit 0;
}

$dict = shift;
$new = shift;

# $suffix = ".au"
$suffix = ".ross.wav";

load_data();

open(FILE, $dict) || die "$0: can't open $dict: $!\n";
open(NEW, ">$new") || die "$0: can't open $new: $!\n";
$inform = 0;
while (<FILE>) {
    print NEW $_;
    if (m/^\<ENTRY/) {
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
#	if ( $word =~ /^julyurl/ ) {
#	    print "Found $word\n";
#	}
        $inform++;
        if (($inform % 1000)==0) {
            print "$inform entries processed\n";
        }
    }          	
}
close(NEW);
close(FILE);
open(ERROR, ">error.log") || die "$0: can't open error.log: $!\n";
foreach $w (sort keys %words) {
    if($words{$w} ne "X") {
        print ERROR "$w\tnot used in dictionary\n";
    }
}
close(ERROR);





# load_data()
# we could get this info from the file "codes.log" made by soxy.pl ... 
# 
sub load_data {
    open(INDEX, "audio.dat") || die "$0: can't open audio.dat: $!\n";
    while(<INDEX>) {
        s/\n//;
        $file = $_;
        $word = $file;
        $word =~ s/\.(\w|\.)+$//;
        $words{$word} = "";
    }
    close(INDEX);
}


#new_data()
sub new_data {
    my ($word) = @_;
    if(defined  $words{$word}) {
        print NEW '<SOUND><SNDI>' . $word . $suffix . '</SNDI></SOUND>' . "\n";
        $words{$word} = "X";
    }
}

#new_data()
sub new_opt_data {
    my ($with, $without) = @_;
    if((defined  $words{$with})||(defined  $words{$without})) {
        print NEW '<SOUND>';
        if(defined $words{$with}) {
            print NEW '<SNDI>' . $with . $suffix . '</SNDI>';
            $words{$with} = "X";
        }
        if(defined $words{$without}) {
            print NEW '<SNDI>' . $without . $suffix . '</SNDI>';
            $words{$without} = "X";
        }
        print NEW '</SOUND>'."\n";
    }
}

