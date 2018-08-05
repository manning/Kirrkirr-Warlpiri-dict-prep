README FOR KIRRKIRR
===================

This is a brief description of how regular "kirrkirr tasks" are done.
For more info see the "readme.txt" file in each subdirectory or email
Kevin <kjansz@cs.usyd.edu.au> or <kjansz@netscape.net> or Chris
<cmanning@acm.org>.


MAKING A NEW XML FILE
=====================

The original XML content file is created from sources supplied from the
Warlpiri dictionary project, which can be found under
/project/kirrkirr/data.  They are converted to XML via a Perl script
that lives in /project/kirrkirr/src/wrl-to-xml.  Scripts that do that
operation and the output of them live in
/project/kirrkirr/data/wrl-proc.

When a new XML file is created there are three (previously 4) types of
tags that need to be added before the index is made: frequency (FREQ),
sound files (SOUND-SNDI)& picture files (IMAGE-IMGI) (& collocations
(COLLOC-COLLI))

[See the file remake.csh in this directory for up-to-date commands - CDM]

So, starting from a new file newWrl.xml

(1) in the "collocations" directory run:
        perl incorp.pl newWrl.xml collWrl.xml
    this adds the freq data (and colloc data from the .dat files when
    uncommented) 
(2) in the "audio" directory run:
        perl incorp_audio.pl collWrl.xml audWrl.xml
    this adds links to sound files for suitable entries (the list of sound
    files is in audio.dat while the actual files are in the www/audio dir)
(3) in the "pics" directory run:
        perl restrict_pics.pl audWrl.xml data.log
    this allocates pictures to entries based on their gloss, putting the
    results in data.log. This file can have english added to it using
    the incorp_eng.pl script in the collocation dir. (a more generous
    allocation that includes any text in the entry is done by
    allocate_pics.pl). The allocation of pics can be done by editing the 
    .dat files (see readme.txt). Next:
        perl incorp_pics.pl audWrl.xml Wrl.xml
    this adds the IMAGE tags to the entries

The editing of the XML file is complete: Wrl.xml


MAKING AN INDEX FILE (.clk FILE)
================================

The kirrkirr program requires a prebuilt index of the .xml file, by
convention named with the same name but the suffix .clk.  The .clk file
is a binary file, containing serialized Java objects.  Any time that any
of the objects types contained in this file are altered (e.g., the
CTHashTable, and dictEntry classes), this index file needs to be
recreated.  If they don't correspond, kirrkirr will error out on startup
with a message about:

	Local class not compatible: stream classdesc serialversionUID= ...

If click.jar and patbin132.zip is in you're CLASSPATH, or in the
"src/kirrkirr" directory, run: 
        java -mx30m -ms20m IndexMaker Wrl.xml Wrl.clk 
This makes the index for kirrkirr. To limit the index to be just for the first
"N" entries use the -L option, eg: java IndexMaker Wrl.xml smallWrl.clk -L50


TO RUN KIRRKIRR AS AN APPLICATION
=================================

Kirrkirr requires the following in your CLASSPATH:
	click.jar/nclick.jar
	patbin13(2).zip 	[regular expressions]
	swing-1.1.jar		[if using JDK1.1.x]
Run:

	java -mx20m -ms20m clickText Wrl.xml Wrl.clk html

So perhaps one can use:
	cd /project/kirrkirr/src/kirrkirr
	source ../../misc/setup
	java -mx20m clickText ../../misc/sWrl.xml ../../misc/sWrl.clk ../../www/runtime/html 

Note that sound does not work when you run it as an application.


TO RUN KIRRKIRR AS AN APPLET
============================

You kneed the same three archives listed above.  Look in
/project/kirrkirr/www/runtime for examples of the kind of .html files to
use.  


TO CREATE NEW HTML
==================

The current html was generated on a Windows system.  It could only be
done on a windows system as it needs to use the msxsl.exe application 
in the "xml2html" dir. The computer needs perl installed to be able to run the
scripts (I use ActiveState's perl for win32 - there's a link from the
www.perl.org site) 

taking off the <?XML..> and <DICTIONARY>  tags from teh top and bottom
of the file, run: 
	perl runner.pl <cropped XML file> 

this will take about 2 hours. Keep an occasional watch, because if it
runs into an error with a file an error message will be spat out and all
future work may be corrupted. You will need to kill the script and fix
the prob before running the process again from scratch.

The current .xsl file derives from an early draft version of XSL and
cannot be run through any current XSL processor.  This should be
updated soon.  One can find info on current XSL processors at
http://www.w3.org/Style/XSL/.  There are several written in Java.
[Chris has been using XT for producing formatted versions of the
warlpiri dictionary.  See the files in the XT subdirectory of the
xml2html directory.]


RECOMPILING KIRRKIRR
====================

You need swing in your CLASSPATH.  Try:

	source /project/kirrkirr/misc/setup

The file remake.csh will build current optimized and unoptimized .jar files.

Kevin: If a change is made to a java source file in the "src/kirrkirr" 
directory do the following for an optimised archive (click.jar):
javac *.java       (in the kirrkirr directory)
cd optimo
mv ../*.class .
perl optimo.pl      (be sure the file optimo.dat has an up-to-date list of the classes)
jar cvf click.jar *.class

Warning: if there are changes made to dictField or dictEntry, old index
files will no longer work as they contain a serialised version of the
old class. Hence the indexes will have to be re-made.

Chris: I've found the following easiest to generate an optimized version:
	rm *.class
	javac -O *.java
	% expect a compiler error, certainly through 1.1.7B
	% TableSorter won't compile optimised;
        % HtmlPanel, Fun, SearchPanel results are buggy
	javac TableSorter.java HtmlPanel.java Fun.java SearchPanel.java
	jar -cf nclick-opt.jar *.class

Or in other words, the Java optimiser is currently so buggy that it is
only just worth using it.  


REBUILDING javadoc
==================

javadoc -d /project/kirrkirr/javadoc/ *.java

Then look at http://www.sultry.arts.usyd.edu.au/javadoc/


REGULAR EXPRESSIONS (patbin132.zip)
==================================

The regular expression package used now (march 1999) lives at:

	http://javaregex.com/

The current version is 1.3.2.

[Chris 21 Apr 2000: There's now a version 1.4.  We haven't tried it.
It wasn't clear that it did anything in particular for us.
ALSO NOTE: There are different patbin versions for different JDK releases,
whereas we've just used the same one everywhere. Dangerous?]


GETTING RID OF ^M'S FROM KEVIN'S FILES
======================================

tr -d '\r' < english.dat > english.new


WHAT THE USER INTERFACE IS CONSTRUCTED OUT OF
=============================================

[cdm: I started this, but it is still quite incomplete]

clickText (JPanel)
    BoxLayout vertical
	toolPanel (JPanel, BoxLayout)
	centre (JPanel, BoxLayout horizonal)
	    spacer 10 pixels
	    sp_jHeadWords (JScrollPane)
	    splitPane (JSplitPane)
		tabbedPane (North) 
		bottomPane (JPanel)
	statusBar
		    GraphPanel (JPanel, now GridBagLayout)
			Fun growx, growy
			centreP (JPanel) [the search stuff, fixed size]
			searchBox (JTextField) // area to enter search string
			s1 (JLabel) //  text label for "Search : "
			filter (JButton) // button for "Filter List"
			reset (JButton) // button for "Reset List"

		     SearchPanel (JPanel, GridBagLayout) [was BoxLayout]
			p0 () // the whole area is divided into three portion, where this is the first / top
			    p00 [current search details]
				srchP (JPanel) // the panel for the search portion
				sl (JLabel) // label for " Search : "
				searchBox (JTextField) // tetx input area
				start (JButton) // button for "Start"
				stop (JButton) // button for "Stop"
				progP (JPanel) // panel for the search's progress 	     
				pl (JLabel) // label for "Progress :"
				progressBar (JProgressBar) // the "animated" progress bar
				progressLabel (JLabel) // label for "type in your query..."
			    p01 (JPanel) // panel on the beside p00 ( "match words in" )
				headwords (JRadioButton) // radio button for "Warlpiri Headwords"
				english (JRadioButton) // radio button for "English Gloss"
				anyfield (JRadioButton) // radio button for "Anywhere"
  			p1 [if ! small] // the whole area of left middle portion
			    p10 [fuzzy/regex/plain] 
				fuzzy (JRadioButton) // radio button for "Fuzzy Spelling"
				regex (JRadioButton) // radio button for "Regular Expression"
				plain (JRadioButton) // radio button for "Plain"
			     p11 [only entries from] // right side of p10 / right middle portion
				results (JRadioButton) // radio button for "Results Table"
				list (JRadioButton) // radio button for "Current word list"
				dictionary (JRadioButton) // radio button for "Whole word list"
			table (JTable) // table for the search results just below p1
			scrollpane // scrollbar
	   		p30 (JPanel, BoxLayout) [results to main list] // the portion just above "HTML Panel"
			    highlighted (JRadioButton) // radio button for "Highlighted results"	
			    all_field (JRadioButton) // radio button for "All results"
			    highlight (JButton) // button for "Highlight in list"
			    copy (JButton) // button for "Make list"
			    reset (JButton) // button for "Reset List"

		     MediaPanel (ClickTextPanel extends JPanel, BoxLayout)
			SoundPanel
			    butt_p (JPanel)
				playAu (JButton) // button for "Play Sound"
				stopAu (JButton) // button for "Stop"
				previous (JButton) // button for "<<"
				next (JButton) // button for ">>"
				currentLabel (JLabel) // text label for "10 of 10"
    			    dir_p (JPanel)
				iconLabel (JLabel) 
			    p (JPanel)
			p2 (BoxLayout Y_AXIS) // Panel for "See Illustrations"
			    pictPane // JScrollPane
				pictVp (viewport)
				    pictLabel 
			    butt_p (JPanel, FlowLayout)
				previous // button for " << Previous Picture"
				currentLabel // label for "10 of 10"
				next // button for "Next Picture >>"

		     HtmlPanel (ClickTextPanel extends JPanel, Boxlayout) // bottom panel of clickText
			html (JEditorPane) 
			scroller (JScrollPane) // scrollbar at the side
			copybutton (JButton) // button for "Copy"
			keepbutton (JButton) // button for "Keep"
			vp (viewport) // viewport to view content

		     NotesPanel (ClickTextPanel extends JPanel, Boxlayout)
			textnotes (JTextArea) // area to enter user's notes
			copybutton (JButton) // button for "Copy"
			scrollPane (JScrollPane) // scrollbar

