#! /bin/sh
home=/Users/manning/Kirrkirr/Kirrkirr-Warlpiri-dict-prep
prog=$home/wrl-to-xml/wrl-xml-new.pl
src=$home/data/wrl-proc/Wrl

$prog $src >newWrl.xml 2>newWrl.err
