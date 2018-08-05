#! /usr/local/bin/tcsh -f

if ($?CLASSPATH) then
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar:$CLASSPATH
else
setenv CLASSPATH /usr/local/src/java/jclark/xt.jar:/usr/local/src/java/jclark/xp.jar:/usr/local/src/java/jclark/sax.jar
endif

# only rebuild ones that don't exist...
if (! -r "$3") then
  java -mx20m com.jclark.xsl.sax.Driver "$1" "$2" "$3"
endif
