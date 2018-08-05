#!/usr/local/bin/perl

while (<>)
{
  s/&amp;/\\&/g;
  s/&lt;/\$<\$/g;
  s/&gt;/\$>\$/g;
  s/"([A-Za-z])/``\1/g;
  s/([A-Za-z])"/\1''/g;
  s/#/\\#/g;
  s/_/\\_/g;
  s/%/\\%/g;
  print;
}
