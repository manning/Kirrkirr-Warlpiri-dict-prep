#!/usr/bin/env python

import sys
import re
import csv
import os

# incorp-pics.py pictures.csv-file input-xml output-xml [images-directory]

if len(sys.argv) < 4:
    print("Too few args. Need: pictures-db input-xml output-xml [images-directory]")
    exit()

pictures_db = sys.argv[1]
in_xml = sys.argv[2]
out_xml = sys.argv[3]

p = re.compile('<HW[^>]*>([^<]+)<\/HW>')
p2 = re.compile('<\/ENTRY>')
p3 = re.compile('HNUM="([0-9]+)">')
p4 = re.compile('^#')

filenameIdx = 0   # A
collectionIdx = 1 # B
creditsIdx = 4    # E
processingIdx = 5    # F
firstWordIdx = 10  # K

words = {}

# Read pictures database and map from (picture -> words) to (word -> pictures)
num_pics = 0
num_pics_missing = 0
with open(pictures_db, newline='') as csvfile:
    pics_data = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in pics_data:
        # row is a list
        # Ignore comment rows
        if not p4.search(row[filenameIdx]):
            num_pics = num_pics + 1
            if len(sys.argv) > 4:
                if not os.path.exists(os.path.join(sys.argv[4], row[filenameIdx])):
                    num_pics_missing = num_pics_missing + 1
                    print('File: ' + os.path.join(sys.argv[4], row[filenameIdx]) + ' not found.')
            for word in row[firstWordIdx:]:
                if word != '':
                    words.setdefault(word, []).append((row[filenameIdx], row[creditsIdx]))

# Read XML file and write XML file with pictures
amp_regex = re.compile(r'&')
less_regex = re.compile(r'<')
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
                        credits = amp_regex.sub("&amp;", credits)
                        credits = less_regex.sub("&lt;", credits)
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
print("File {} has {} pictures, added to {} words via {} associations; {} words and {} pictures not found.".format(
    pictures_db, num_pics, num_words, num_assoc, num_unfound, num_pics_missing))
