MAKING THE HTML DICTIONARY ENTRIES
==================================

The first section discusses what Kevin used (Windows specific).  The
second section discusses revised generation done by Chris (done on Unix,
but mainly platform-independent, given Java, Perl).

KEVIN GENERATION
================

Creating HTML files for dictionary entries from XML
* this requires the msxsl executable to be in the path of the windows system
  as well as perl

Designing/Editing the HTML format:

(1) the XSL style sheet used is: "warlpiri.xsl". To test how changes to
the file will effect the HTML in Kirrkirr do the following:
    run:        msxsl -i <xml file with one sample entry> -s warlpiri.xsl -o <html file>
        eg.     msxsl -i jaa.xml -s warlpiri.xsl -o temp.html

(2) check the appearance with HtmlPanel:
        java HtmlPanel <test html file generated>
    eg. java HtmlPanel teml.html
    (NB the java HTML appearance will look quite different to that in a
browser, so HtmlPanel's representation will be identical to Kirrkirr)


Creating the HTML files for each entry:

The code kevin used is now in htmlgen/kevin_scripts

(1) Cut the headers & footers off the XML dictionary (so the file begins
with the first <ENTRY> tag and ends with the last entry's </ENTRY> tag)
(2) run:        perl runner.pl <edited xml file>
        eg.     perl runner.pl cropped.xml
(3) this will taks some time, and will create a HTML formatted file for
each enty in the dictionary (ie 9000+ files).


How runner.pl works:
* this script calls four perl scripts:
(1) split.pl splits the XML file into a xml file for each entry, named
AAA.xml - ZZZ.xml and creates the .dat files with the arguments to the
other scripts (because *.xml will cause bash to crash if 5000+ files
are matched) 
(2) htmlgen.pl calls msxsl to convert each ???.xml file to ???.html and
deletes the xml files 
(3) splitfix.pl cleans up the msxsl generated HTML and creates ???.fix
files, deleting the html files.  It's a prettyprinter that indents
levels of nesting in the description lists (<DL>).
(4) split_target.pl scans through all the HTML files to which words are
in which file, then scans each file again to fill in the appropriate
HREFs. eg if ja is in AAA.html all HTML pages that have a HREF to "ja"
will be filled in with "AAA.html" 
* for testing, using the -D with runner.pl will stop the scripts from
deleting the intermediate files
eg.     perl runner.pl -D newWrl.xml
(don't use this option with the full dictionary, unless you want 27000
files in your directory). 



CHRIS GENERATION
================

New stuff using jclark's XT Java XSLT processor is in the XT
subdirectory.  This has been used to generate LaTeX and HTML.

Creating HTML files for dictionary entries from XML

Designing/Editing the HTML format:

(1) the XSL style sheet used is: "warlpiri.xsl". To test how changes to
the file will effect the HTML in Kirrkirr do the following:

(2) check the appearance with HtmlPanel [I've done this by running Kirrkirr]


Creating the HTML files for each entry:
--------------------------------------

The code for running html regeneration is in htmlgen

	run:        perl runner.pl <xml file>

This will taks some time, and will create a HTML formatted file for
each enty in the dictionary (ie 9000+ files).  The main system
dependency is the setup for running the Java XSL code.  The current
version uses a wrapper shell script runxt.csh, but one can just change
$command in htmlgen.pl to something appropriate for another system.


How runner.pl works:
* this script calls four perl scripts:
(1) headandtail.pl cuts the headers & footers off the XML dictionary
(so the main file begins with the first <ENTRY> tag and ends with the
last entry's </ENTRY> tag).  This results in three files head.dat,
tail.dat and body.xml. 
(2) split.pl splits the XML file into an xml file for each entry, named
as <headword>.xml, and creates the .dat files with the arguments to the
other scripts (because *.xml will cause bash to crash if 5000+ files
are matched) 
(3) htmlgen.pl calls msxsl to convert each ???.xml file to ???.html and
deletes the xml files 
(3b) splitfix.pl was made as a prettyprinter for HTML files doing levels
of nesting of <DL> lists.  It indents levels of nesting in the
* description lists (<DL>).  It's disused at present.
(5) split_target.pl is now a misnomer.  It used to do complicated things
when there were multiple words in a file.  Now all it does is build an
index based on filenames.
* for testing, using the -D with runner.pl will stop the scripts from
deleting the intermediate files
eg.     perl runner.pl -D newWrl.xml
(don't use this option with the full dictionary, unless you want 27000
files in your directory). 

