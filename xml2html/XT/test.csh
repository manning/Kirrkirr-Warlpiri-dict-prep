#! /usr/local/bin/tcsh -f
setenv PATH /usr/local/java/jdk/bin:$PATH
if ($?CLASSPATH) then
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar:$CLASSPATH
else
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar
endif

java com.jclark.xsl.sax.Driver small.xml warlpiri.xsl small.html
