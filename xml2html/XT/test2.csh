#! /usr/local/bin/tcsh -f
setenv PATH /usr/local/java/jdk/bin:/usr/local/src/java/Xsl/bin:$PATH

# using Xsl

xsl -r warlpiri.xsl small.xml > small.html
