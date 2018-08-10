#!/bin/sh

# home = /project/kirrkirr
home=/Users/manning/Kirrkirr/Kirrkirr-Warlpiri-dict-prep
kirrkirrhome=/Users/manning/Kirrkirr
# This will remake the datafiles, given new sources in:
#       $home/data/wrlpdict-current
# with the usual 1 and 2 letter names, and no other files in the directory
# with such small names.
# or now with a single file in that dir called Wrl

# build XML from WRL
echo "build XML from WRL"
# cd $home/data/wrlpdict-current
# cat j? k? l m? n n? p? r rd t w? y? >$home/data/wrl-proc/Wrl
cp $kirrkirrhome/warlpiri-2018/src/wlp-lexicon_master.txt $home/data/wrl-proc/Wrl
cd $home/data/wrl-proc
./newconv.sh
# frequency (and collocations someday)
echo "frequency (and collocations someday)"
cd $home/collocations
perl incorp-cm.pl $home/data/wrl-proc/newWrl.xml collWrl.xml
# audio
echo audio
cd $kirrkirrhome/distrib/Warlpiri2007/audio
ls -1 > $home/audio/audio.dat
cd $home/audio
perl incorp_audio.pl $home/collocations/collWrl.xml audWrl.xml
rm $home/collocations/collWrl.xml
# pictures
echo pictures
cd $home/pics
perl chrispics.pl images.dat dict.dat
perl incorp_pics.pl $home/audio/audWrl.xml Wrl.xml
rm $home/audio/audWrl.xml
# mv Wrl.xml $home/www/runtime
mv Wrl.xml $home/runtime
# html
echo "skipping making html now"
# echo html
# cd $home/xml2html/htmlgen
# perl runner.pl  $home/runtime/Wrl.xml
# rm -f $home/runtime/html/@*.html
# mv *.html $home/runtime/html

# make censored
echo "censored and small"
cd $home/censor
perl censor.pl badwords.dat $home/runtime/Wrl.xml $home/runtime/censWrl.xml

# make small good
cd $home/censor
perl subset.pl goodwords.dat $home/runtime/Wrl.xml $home/runtime/sWrl.xml

exit
# make .clk files
echo "make .clk files"
cd $home/runtime

java -mx30m -ms20m -cp "nclick.jar:patbin132.zip:" IndexMaker Wrl.xml Wrl.clk
java -mx30m -ms20m -cp "nclick.jar:patbin132.zip:" IndexMaker censWrl.xml censWrl.clk
java -mx30m -ms20m -cp "nclick.jar:patbin132.zip:" IndexMaker sWrl.xml sWrl.clk
