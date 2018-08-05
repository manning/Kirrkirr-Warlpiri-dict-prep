#!/gnu/usr/bin/perl 

#perl split_target fix.dat
# fills in the hrefs and the target fields in the files
# once it works out what word is in what file.

$index = shift;
$DEBUG = 0;
if($index =~ m/-D/) {
    $index = shift;
    $DEBUG = 1;
}


print STDERR "Starting to span files\n";
$count = 0;
open(INDEX, $index) || die "$0: can't open $index: $!\n";
while(<INDEX>) {
    s/\n//;
    $HTML = $_;
    open(FILE, $HTML) || die "$0: can't open $HTML: $!\n";
    $HTML =~ s:\.fix::;
    while(<FILE>) {
        #<DT><a name=""><H1><B>-ja<NUM num="1"></B></H1></a></DT>
        if(m:\<H1\>\<B\>(.+?)\<NUM num\=\"(\d)*?\"\>\<\/B\>\<\/H1\>:) {
            $original = $1;
            $hnum = $2 * 1;
            $word = $1;
            $files{$word}{$hnum} = $HTML;
            $location{$word}{$hnum} = $.;
            $original{$word} = $original;
            #print "$1 at $HTML $location{$1}\n";                        
        }
    }
    $lines{$HTML} = $.;
    $count++;
    print STDERR "$count files spanned\n" if(($count%1000)==0);
    close(FILE);
}
close(INDEX);
print STDERR "spanned $count files\n";

foreach $w (keys %location) {
    foreach $x (keys %{ $location{$w} }) {
        $location{$w}{$x} = ($location{$w}{$x})/($lines{$files{$w}{$x}});
    #print "$w => $location{$w}\n";
    }
}

print STDERR "Starting to complete files\n";
$count = 0;
open(INDEX, $index) || die "$0: can't open $index: $!\n";
while(<INDEX>) {
    s/\n//;
    $HTML = $_;
    open(FILE, $HTML) || die "$0: can't open $HTML: $!\n";
    $HTML =~ s:\.fix::;
    open(NEW, ">$HTML") || die "$0: can't open $HTML: $!\n";
    while(<FILE>) {
        if(m:\<DT\>\<a name=\"\"\>\<H1\>\<B\>(.+?)\<NUM num\=\"(\d)*?\"\>\<\/B\>\<\/H1\>:) {
            print NEW $`;
            $original = $1;
            $word = $1;
            $hnum = $2 * 1;
            print NEW '<DT><a name="'.$location{$word}{$hnum}.'"><H1><B>'.$original;
            if($hnum != 0) {
                print NEW '&nbsp;('.$hnum.')';
            }
            print NEW '</B></H1>';
            print NEW $';
        }
        else {
            $line = $_;
            while($line) {
                if ($line =~ m:\<a href=\"(.*?)\" num=\"(.*?)\"\>(.+?)\<\/a\>:) {
                    $original = $3;
                    $num = $2;
                    $pre = $`;
                    $post = $';
                    $word = $1;
                    if(!(defined $location{$word})) {
                        print NEW "$pre$original";
                        $line = $post;
                    }
                    else {
                        if(!($num =~ m:\d+:)) {
                            @polies = keys %{$location{$word}};
                            if( $#polies >= 1) {
                                $num = 1;
                            } else {
                                $num = 0;
                            }
                        }
                        print NEW "$pre\<a href=\"$files{$word}{$num}\"\>$original\<\/a\>";
                        $line = $post;
                    }
                }
                else {
                    print NEW $line;
                    last;
                }
            }
        }
    }
    close NEW;
    close FILE;
    if($DEBUG == 0) {
        $b = "rm \"$HTML.fix\"";
    }
    $c = `$b`;
    $count++;
    print STDERR "$count files complete\n" if(($count%1000)==0);
}
print STDERR "complete $count files\n"; 
close(INDEX);

print STDERR "printing index.html\n";

# this should print index.html
open(FILE, ">index.html") || die "$0: can't open index.html: $!\n";

print FILE<<"Head";
<HTML><HEAD>
<TITLE></TITLE>
</HEAD><BODY TEXT="#000000" BGCOLOR="#ECFFEC" LINK="#6E6761" VLINK="#551A8B" ALINK="#FF0000">
<TABLE WIDTH="100%">
Head
;

foreach $w (sort (keys %original)) {
    @polies = keys %{$location{$w}};
    foreach $n (@polies) {
        print FILE '<TR>'."\n";
        print FILE '<TD><A HREF="'.$files{$w}{$n}.'">'.$original{$w}.'</A></TD>'."\n";
        print FILE '<TD>'.$files{$w}{$n}.'</TD>'."\n";
        print FILE '<TD>'.$n.'</TD>'."\n";
        print FILE '</TR>'."\n";
    }
}

print FILE<<"Tail";
</TABLE>
</BODY></HTML>
Tail
;
close(FILE);