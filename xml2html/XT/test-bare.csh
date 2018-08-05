#! /usr/local/bin/tcsh -f
# setenv PATH /usr/local/java/jdk/bin:$PATH
if ($?CLASSPATH) then
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar:$CLASSPATH
else
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar
endif

java com.jclark.xsl.sax.Driver small.xml \
   wrl-tex-bare.xsl tmp-bare.tex
./recode-chars.pl <tmp-bare.tex >wrl-bare.tex
rm tmp-bare.tex
latex wrl-bare
dvips wrl-bare

