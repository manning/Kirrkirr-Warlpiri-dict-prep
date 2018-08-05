#!/bin/csh -f

$home = /project/kirrkirr
# This will remake the datafiles, given new sources n:
#       /project/kirrkirr/data/wrlpdict-current
# with the usual 1 and 2 letter names, and no other files in the directory
# with such small names.

# build XML from WRL
echo "build XML from WRL"
cd $home/data/wrlpdict-current
cat j? k? l m? n n? p? r rd t w? y? >$home/data/wrl-proc/Wrl
cd $home/data/wrl-proc
./newconv.sh
# frequency (and collocations someday)
echo "frequency (and collocations someday)"
cd $home/src/collocations
perl incorp-cm.pl $home/data/wrl-proc/newWrl.xml collWrl.xml
# audio
echo audio
cd $home/www/runtime/audio/
ls -1 > $home/src/audio/audio.dat
cd $home/src/audio
perl incorp_audio.pl $home/src/collocations/collWrl.xml audWrl.xml
rm $home/src/collocations/collWrl.xml
# pictures
echo pictures
cd $home/src/pics
perl chrispics.pl images.dat dict.dat
perl incorp_pics.pl $home/src/audio/audWrl.xml Wrl.xml
rm $home/src/audio/audWrl.xml
mv Wrl.xml $home/www/runtime
# html
echo html
cd $home/src/xml2html/htmlgen
perl runner.pl  $home/www/runtime/Wrl.xml
rm -f $home/www/runtime/html/@*.html
mv *.html $home/www/runtime/html

# make censored
echo "censored and small"
cd $home/src/censor
perl censor.pl badwords.dat $home/www/runtime/Wrl.xml $home/www/runtime/censWrl.xml

# make small good
cd $home/src/censor
perl subset.pl goodwords.dat $home/www/runtime/Wrl.xml $home/www/runtime/sWrl.xml

# make .clk files
echo "make .clk files"
cd $home/www/runtime
setenv CLASSPATH nclick.jar:patbin132.zip:
java -mx30m -ms20m IndexMaker Wrl.xml Wrl.clk 
java -mx30m -ms20m IndexMaker censWrl.xml censWrl.clk
java -mx30m -ms20m IndexMaker sWrl.xml sWrl.clk
