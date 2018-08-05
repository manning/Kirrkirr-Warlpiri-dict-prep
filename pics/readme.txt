CHRIS

Kevin's approximate picture inclusion clearly doesn't work for really
getting it right.  I've used good old hand specification of pictures
that go with words.  The file "images.dat" describes words going with
each image.  The file chrispics.pl does a reversal of that to yield a
file, here dict-chris.dat.  This can be incorporated into the dictionary
with Kevin's incorp_pics.pl.


KEVIN

To incorporate pictures:

1. make a file pics.dat in the format:
<filename>#<description>
eg. 
waltail.jpeg#tail of a wallaby

2. run perl restrict_pics.pl <xml dictionary> <results file>
this will put in the results file which pictures it thinks should
go with which entries (running incorp_eng.pl on this file may make 
things easier. If the script used the description instead of the filename
to match an item in the entry a ":word" is put next to the filename, where
"word" is the description word used.
marlu   kangaroo.jpg    waltail.jpeg:tail
(the script allocate_pics.pl uses any text in the entry (examples
included), where as restrict_pics.pl uses only word in the definition or
gloss) 

3. edit the file "dict.dat" in case there are errors in the
allocations. Be sure to keep the format:
<headword>#<filename>:<filename>:
eg.
marlu#kangaroo.jpeg:waltail.jpeg:
edit to:
marlu#kangaroo.jpeg:

4. run perl incorp_pics.pl <xml dictionary> <new dictionary file name>
and the appropriate tags will be added

