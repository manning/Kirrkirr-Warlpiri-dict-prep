#! /usr/local/bin/tcsh -f
# setenv PATH /usr/local/java/jdk/bin:$PATH
if ($?CLASSPATH) then
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar:$CLASSPATH
else
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar
endif

java -ms80m -mx120m com.jclark.xsl.sax.Driver \
   /project/kirrkirr/data/wrl-proc/newWrl.xml \
   wrl-tex.xsl tmp.tex
./recode-chars.pl <tmp.tex >warlpiri.tex
rm tmp.tex

