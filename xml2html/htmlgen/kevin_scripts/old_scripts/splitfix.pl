#!/gnu/usr/bin/perl 

#perl splitfix.pl html.dat>
# makes ???.html.fix files with layed out html - makes line number positions predictable

$index = shift;
$inform = 0;
open(INDEX, $index) || die "$0: can't open $index: $!\n";
while(<INDEX>) {
    s/\n//;
    $HTML = $_;
    open(FILE, $HTML) || die "$0: can't open $HTML: $!\n";
    open(NEW, ">$HTML.fix") || die "$0: can't open $HTML.fix: $!\n";
    while(<FILE>) {
        if(m:^\s+$:) {
            next;
        }
        if(m:\<DL:) {
            $dl++;
        }
        for($i=0 ; $i<($dl-1) ; $i++) {
            print NEW "    ";
        }
        if(m:\<\/DL:) {
            $dl--;
        }
        print NEW;
    }
    close(NEW);
    close(FILE);
    $b = `rm $HTML`;
    $inform++;
    if(($inform % 500) == 0) {
        print STDERR "$inform files fixed\n";
    }
}
