#!/usr/bin/env python

import sys
import re
import csv

# incorp-pics.py pictures.csv-file input-xml output-xml

if len(sys.argv) < 4:
    print("Too few args. Need: pictures-db input-xml output-xml")
    exit()

pictures_db = sys.argv[1]
in_xml = sys.argv[2]
out_xml = sys.argv[3]

p = re.compile('<HW[^>]*>([^<]+)<\/HW>')
p2 = re.compile('<\/ENTRY>')
p3 = re.compile('HNUM="([0-9]+)">')
p4 = re.compile('^#')


words = {}

# Read pictures database and map from (picture -> words) to (word -> pictures)
num_pics = 0
with open(pictures_db, newline='') as csvfile:
    pics_data = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in pics_data:
        # row is a list
        # Ignore comment rows
        if not p4.search(row[0]):
            num_pics = num_pics + 1
            for word in row[7:]:
                if word != '':
                    words.setdefault(word, []).append((row[0], row[4]))

# Read XML file and write XML file with pictures
num_assoc = 0
num_words = 0
key = ""
out_file = open(out_xml, "w")
with open(in_xml) as f:
    for line in f:
        m = p.search(line)
        if m != None:
            m3 = p3.search(line)
            if m3 != None:
                key = m.group(1) + '*' + m3.group(1) + '*'
            else:
                key = m.group(1)
        m2 = p2.search(line)
        if m2 != None:
            if key in words:
                num_words = num_words + 1
                out_file.write('<IMAGE>')
                pics = words[key]
                for (fname, credits) in pics:
                    num_assoc = num_assoc + 1
                    if credits != '':
                        out_file.write('<IMGI CREDITS="' + credits + '">')
                    else:
                        out_file.write('<IMGI>')
                    out_file.write(fname + '</IMGI>')
                out_file.write('</IMAGE>\n')
                # delete found key
                del words[key]
        # always copy in to out
        out_file.write(line)
out_file.close()

# Print out errors (words not found)
num_unfound = len(words)
for key in sorted(words.keys()):
    print(key + ' - not found.')

# Print stats
print("File {} has {} pictures, added to {} words via {} associations; {} words not found.".format(
    pictures_db, num_pics, num_words, num_assoc, num_unfound))
