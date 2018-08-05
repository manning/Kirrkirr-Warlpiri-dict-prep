#!/gnu/usr/bin/perl 

#perl split_target fix.dat
# fills in the hrefs and the target fields in the files
# once it works out what word is in what file.

$index = shift;

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
            $word =~ s/-//g;
            if ( $word =~ m/\(.*?\)/ ) {
                $no_opt = $word;
                $no_opt =~ s/\(.+?\)//g;
                $word =~ s/\(//g;
                $word =~ s/\)//g;
                $files{$no_opt}{$hnum} = $HTML;
                $location{$no_opt}{$hnum} = $.;
                $files{$word}{$hnum} = $HTML;
                $location{$word}{$hnum} = $.;
            }
            else {
                $files{$word}{$hnum} = $HTML;
                $location{$word}{$hnum} = $.;
            }
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
            $word =~ s/-//g;
            $word =~ s/\(//g;
            $word =~ s/\)//g;
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
                if ($line =~ m:\<a href=\"\"\>(.+?)\<\/a\>:) {
                    $original = $1;
                    $pre = $`;
                    $post = $';
                    $word = $1;
                    $word =~ s/-//g;
                    $word =~ s/\(//g;
                    $word =~ s/\)//g;
                    if(!(defined $location{$word})) {
                        print NEW "$pre$original";
                        $line = $post;
                    }
                    else {
                        @polies = keys %{$location{$word}};
                        #print "$HTML: $word $#polies+1\n";
                        if( $#polies >= 1) {
                            $i = 1;
                        } else {
                            $i = 0;
                        }
                        print NEW "$pre\<a href=\"$files{$word}{$i}\#$location{$word}{$i}\"\>$original\<\/a\>";
                        $line = $post;
                    }
                }
                else {
                    print NEW $line;
                    last;
                }
            }
            #s:\<a href=\"\"\>(.+?)\<\/a\>:\<a href=\"\#$location{$1}\"\>$1\<\/a\>:gi;
            #print NEW $_;
        }
    }
    close NEW;
    close FILE;
    $b = "rm $HTML.fix";
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
        print FILE '<TD><A HREF="'.$files{$w}{$n}.'#'.$location{$w}{$n}.'">'.$original{$w}.'</A></TD>'."\n";
        print FILE '<TD>'.$files{$w}{$n}.'</TD>'."\n";
        print FILE '<TD>'.$location{$w}{$n}.'</TD>'."\n";
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