Original AIFF files live in: 
	/project/kirrkirr/data/wrl-audio
Currently, there are about 260 words spoken by Ross in the Ross subdirectory


Converting AIFF files to au:
----------------------------

Kevin:

(1) requires a windows system that has perl installed (sox is in the sox
directory) 

(2) run:        perl soxy.pl <list of aiff files>
        eg.     perl soxy.pl *.ross
because sox is DOS program the script makes aiff files of the type AAA-ZZZ.aiff
before converting with sox to AAA-ZZZ.au and then last of all renames the files
to be their orignal names with the au extension

Chris:

Actually SoX runs perfectly well on Unix!  See:

	http://home.sprynet.com/~cbagwell/sox.html

It's now alive and well in /usr/local/bin/sox
The following will convert an aiff file okay:

	sox -auto -t aiff jaja.ross -r 8012 -U -b jaja.au

Resultant .au files live in /project/kirrkirr/www/audio/


Incorporating references to sound files in the XML dictionary:
--------------------------------------------------------------

(1) run         perl incorp_audio.pl <xml file> <new xml filename>
        eg.     perl incorp_audio.pl nonaudio.xml Wrl.xml

This program relies on the audio.dat file in /project/kirrkirr/src/audio/
This file can be regenerated with:
	cd /project/kirrkirr/www/runtime/audio/
	ls -1 > /project/kirrkirr/src/audio/audio.dat

(2) check the file "error.log" for audio files that have not been
allocated to a dictionary entry


Non-Warlpiri sounds in the audio directory:
-------------------------------------------

There are 3 non-Warlpiri sounds in the audio directory currently:
	gong.au		Used at startup
	drip.au		Currently unused; was used in Fun.java
	computer.au	Currently unused, but could be background to 
				searching, etc.
These should be put in a non-Warlpiri directory
(The other sounds that used to be in the directory have been moved to
junk-audio.)
