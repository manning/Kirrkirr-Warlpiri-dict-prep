#!/usr/bin/env python3

import re

# To do: update this script and database to support hwnums!

# The plague of backslashes just like Java!
p = re.compile('<HW[^>]*>([^<]+)<\/HW>')
p2 = re.compile('<IMGI[^>]*>([^<]+)<\/IMGI>')
p3 = re.compile('HNUM="([0-9]+)">')
p4 = re.compile('CREDITS="([^"]+)">')
p5 = re.compile('<LAT>(.*)</LAT>')

pictures = {}

headword = None

with open("/Users/manning/Kirrkirr/WarlpiriKirrkirr/Kirrkirr404/Kirrkirr 4.0.4 Warlpiri/Warlpiri/Wrl.xml") as f:
    for line in f:
        # print("Line is: " + line)
        m = p.search(line)
        if m != None:
            headword = m.group(1)
            # print('Headword = ' + headword)
            hnum = ""
            latin = ""
            m3 = p3.search(line)
            if m3 != None:
                hnum = m3.group(1)
        printedHeadword = False
        m5 = p5.search(line)
        if m5 != None:
            latin = m5.group(1)
        for m2 in p2.finditer(line):
            m4 = p4.search(line)
            if m4 != None:
                credits = m4.group(1)
            else:
                credits = ""
            if not printedHeadword:
                print(headword + "#", end = '')
                print(hnum + "#", end = '')
                print(latin + "#", end = '')
                printedHeadword = True
            print(m2.group(1) + ':', end = '')
            print(credits + '#', end='')
            pictures.setdefault(m2.group(1), []).append((headword, hnum, credits, latin))
        if printedHeadword:
            print()

print()
print()

for pic in pictures:
    print(pic, end = '')
    first = True
    for (word, hnum, credits, latin) in pictures[pic]:
        if first:
            print('#' + latin, end='')
            print('#' + credits, end ='')
            first = False
        if hnum == "":
            print('#' + word, end = '')
        else:
            print('#' + word + "*" + hnum + "*", end='')
    print()
