#!/usr/local/bin/perl

if($#ARGV <= 0) {
    print "Usage: perl incorp_pics.pl <xml dictionary> <new filename>\n\n";
    exit 0;
}

$dict = shift;
$new = shift;

load_data();
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
        new_data($word);
	$inform++;
        if(($inform % 500)==0) {
            print "$inform entries processed\n";
        }
    }          	
}
close(NEW);
close(FILE);
open(ERROR, ">error.log") || die "$0: can't open error.log: $!\n";
foreach $w (keys %words) {
    if($words{$w} ne "X") {
        print ERROR "$w\tnot used in dictionary\n";
    }
}
close(ERROR);





# load_data()
# 
sub load_data {
    open(FILE, "dict.dat") || die "$0: can't open dict.dat: $!\n";
    while(<FILE>) {
        s/\n//g;
        ($key, $value) = split /#/;
	$key =~ s/-//g; # remove hyphens
        @files = split /:/, $value;
        foreach $f (@files) {
            $data{$key}{$f} = "X";
        }
    }      
    close(FILE);
}


#new_data()
sub new_data {
    my ($word) = @_;
    if(defined  $data{$word}) {
        print NEW '<IMAGE>';
        foreach $file (keys %{$data{$word}}) {
            print NEW '<IMGI>'.$file.'</IMGI>';
        }
        print NEW '</IMAGE>'."\n";
    }
}
