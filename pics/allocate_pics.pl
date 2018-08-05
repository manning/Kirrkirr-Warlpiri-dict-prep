#!/gnu/usr/bin/perl

if($#ARGV <= 0) {
    print "Usage: perl allocate_pics.pl <ml dictionary> <results file>\n\n";
    exit 0;
}

$dict = shift;
$new = shift;

load_data();
open(FILE, $dict) || die "$0: can't open $dict: $!\n";
open(NEW, ">$new") || die "$0: can't open $new: $!\n";
$inform = 0;
$/ = "";                                #this means one (\n separated) parargraph is read in at a time
$opt = 0;
while(<FILE>) {
    $entry = $_;
    if(m/\<HW.*?\<\/HW\>/) {
	$word = $&;
        $word =~ s/-//g;
	$word =~ s/\<.+?\>//g;
	$word =~ s/\n//g;
        #print "match! $word \n";
        if ( $word =~ m/\(.*?\)/ ) {
            $with_opt = $word;
            $no_opt = $word;
            $no_opt =~ s/\(.+?\)//g;
            $with_opt =~ s/\(//g;
            $with_opt =~ s/\)//g;
	    $opt = 1;
	}
	else {
	    $opt = 0;
	}
        $inform++;
        if(($inform % 500)==0) {
            print "$inform entries processed\n";
        }
        $entry =~ s/\n/ /sg;
        $entry =~ s/\<.+?\>/  /sg;
        if($opt) {
            new_opt_data($with_opt, $no_opt);
        } else {
            new_data($word);
        }
    }
}
close(NEW);
close(FILE);
open(DATA, ">dict.dat") ||  die "$0: can't open dict.dat: $!\n";
foreach $word (sort keys %data) {
    print DATA "$word#";
    foreach $file (keys %{$data{$word}}) {
        print DATA "$file:";
    }
    print DATA "\n";
}
close(DATA);
open(ERROR, ">error.log") ||  die "$0: can't open error.log: $!\n";
foreach $file (keys %file2desc) {
    if($used{$file} ne "y") {
        print ERROR "$file not used\n";
    }
}
close(ERROR);
print "\a\a";


# load_data()
# 
# 
sub load_data {
    open(FILE, "pics.dat") || die "$0: can't open pics.dat: $!\n";
    while(<FILE>) {
        s/\n//g;
        ($key, $value) = split /#/;
        $file2desc{$key} = $value;
    }      
    close(FILE);
}


#new_data()
sub new_data {
    my ($word) = @_;
    my $allocated = 0;

    foreach $name (keys %file2desc) {
        $file = $name;
        $file =~ s/\.\w+$//;
        if (($word =~ m/\b$file\b/i)||($entry =~ m/\b$file\b/i)) {
            print NEW "$word\t" if $allocated == 0;
            $allocated++;
            print NEW "$name\t";
            $data{$word}{$name} = "X";
            $used{$name} = "y";
        } else {
            @keyz = split /:/, $file2desc{$name};
            foreach $keyw (@keyz) {
                if (($word =~ m/\b$keyw\b/i)||($entry =~ m/\b$keyw\b/i)) {
                     print NEW "$word\t" if $allocated == 0;
                     $allocated++;
                     print NEW "$name:$keyw\t";
                     $data{$word}{$name} = "X";
                     $used{$name} = "y";
                }
            }
        }
    }
    print NEW "\n" if $allocated > 0;
}

#new_data()
sub new_opt_data {
    my ($with, $without) = @_;
    my $word = $with;
    my $allocated = 0;

    foreach $name (keys %file2desc) {
        $file = $name;
        $file =~ s/\.\w+$//;
        if (($word =~ m/\b$file\b/i)||($entry =~ m/\b$file\b/i)) {
            print NEW "$word\t" if $allocated == 0;
            $allocated++;
            print NEW "$name\t";
            $data{$with}{$name} = "X";
            $used{$name} = "y";
        } else {
            @keyz = split /:/, $file2desc{$name};
            foreach $keyw (@keyz) {
                if (($word =~ m/\b$keyw\b/i)||($entry =~ m/\b$keyw\b/i)) {
                     print NEW "$word\t" if $allocated == 0;
                     $allocated++;
                     print NEW "$name:$keyw\t";
                     $data{$with}{$name} = "X";
                     $used{$name} = "y";
                }
            }
        }
    }
    $word = $without;
    foreach $name (keys %file2desc) {
        $file = $name;
        $file =~ s/\.\w+$//;
        if (($word =~ m/\b$file\b/i)||($entry =~ m/\b$file\b/i)) {
            print NEW "$word\t" if $allocated == 0;
            $allocated++;
            print NEW "$name\t";
            $data{$with}{$name} = "X";
            $used{$name} = "y";
        } else {
            @keyz = split /:/, $file2desc{$name};
            foreach $keyw (@keyz) {
                if (($word =~ m/\b$keyw\b/i)||($entry =~ m/\b$keyw\b/i)) {
                     print NEW "$word\t" if $allocated == 0;
                     $allocated++;
                     print NEW "$name:$keyw\t";
                     $data{$with}{$name} = "X";
                     $used{$name} = "y";
                }
            }
        }
    }
    print NEW "\n" if $allocated > 0;
}
