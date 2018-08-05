#!/gnu/usr/bin/perl

$dict = shift;

open(ENG, ">english.dat") || die "$0: can't open english.dat: $!\n";
open(FILE, $dict) || die "$0: can't open $dict: $!\n";
$inform = 0;
while(<FILE>) {
    if(m/^\<ENTRY\>/) {
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
	    new_data($with_opt, $no_opt);
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
close(FILE);
close(ENG);


#new_data()
sub new_data {
    my ($w, $w2) = @_;
    my $line = "";
    
    while(<FILE>) {
        if(m/^\<\/ENTRY\>/) {
            last;
        }
        elsif (m/^\<GL\>/) {
            #elsif ((m/^\<GL\>/)||(m/^\<DEF\>/)) 
            s/-//g;
            s/\<.+?\>//g;
            s/\n//g;
            $line .= $_;
        }           
    }
    $key = join '#', $w, $line;
    print ENG "$key\n";
    if (defined $w2) {
        $key = join '#', $w2, $line;
        print ENG "$key\n";
    }    
}

