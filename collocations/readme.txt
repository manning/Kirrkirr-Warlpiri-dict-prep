There are three main perl scripts here:
kollok.pl - calculates collocations and prints them in a table 
	for printing and verifying the results.
	kollok-cm.pl is a variant version that chris has worked on with
	some different output formatting to interface with other tools.
	Also, some changes: don't count reflexively!
	I think it's now generally better!
	./kollok-cm.pl hws.txt suffix.txt CORPUS2.TXT -C
kollok2.pl - creates the .dat files required by incorp.pl 
incorp.pl - adds the frequency data and collocate info to the XML 
	file. (at present the collocation stuff is commented out and
	only the frequency tag is added)

incorp-cm.pl -- adds the frequency data to the XML file.  This is what
Chris is currently using.  (At present the collocation stuff is commented
out and has not been updated; only the frequency tag is added.  It seems
that really the collocation stuff should be added _before_ conversion to
Warlpiri).

In the EnglishFL directory, the script incorp_english.pl adds the
english gloss in brackets next to any Warlpiri words it finds in the given
file.  It needs english.dat file in current directory, so:
> cd EnglishFL
> perl incorp_eng.pl ../unicount.sort ../unicount-eng.sort




----
CORPORA
----

The basic collections of Warlpiri text are in:

/project/kirrkirr/data/texts-jhs	Material from Jane Simpson
/project/kirrkirr/data/texts-laughren	Material from Mary Laughren

There is a lot of material repeated within and across collections.
And this data is fairly unclean with various forms of random markup.

Kevin made a "clean" text file in ./CORPUS.TXT

However, there seem to be no particular records of what it contains, or
of how it was made....


----
OTHER TOOLS
----
kollok-cm.pl is designed to produce output (with the -C flag) that can
feed in to Ted Dunning's crl-tools

/usr/local/corpora/src/crl-tools/makecontingency.pl <count.dat unicount.dat 0
| /usr/local/corpora/src/crl-tools/chi2 -l 2 2 | sort -n -r | more


Unknown word analysis:
> cut -d ' ' -f 1 error.log | sort | uniq -c | sort -n -r > unknown.sort

