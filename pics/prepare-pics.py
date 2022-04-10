#!/usr/bin/env python

import sys
import re
import csv
import os
import pathlib
import subprocess
from PIL import Image

# prepare-pics.py - This deals with making pictures of a suitable size, brightness, ackowledgements, etc.
#
# TODO:
# Maybe the first thing to do is just to add a list of keywords for phases to run, like trim, autotone.
# Then need to somehow handle filenames as we go. Not that hard, I guess.
# And place output back in collection directory
#
# prepare-pics.py pictures-file.csv piccybank-folder

if len(sys.argv) < 3:
    print("Too few args. Need: pictures-file.csv piccybank-folder")
    exit()

pictures_db = sys.argv[1]
piccybank = sys.argv[2]

p4 = re.compile('^#')

filenameIdx = 0   # A
collectionIdx = 1 # B
creditsIdx = 4    # E
processingIdx = 5    # F
firstWordIdx = 10  # K
originals = "ORIGINALS"
font = 'AvantGarde-Book'

# Read pictures database and make dict from files to lines of CSV file
# Filenames are assumed to be globally unique
pict_dict = {}
collections = []

num_pics = 0
with open(pictures_db, newline='') as csvfile:
    pics_data = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in pics_data:
        # row is a list
        # Ignore comment rows
        if not p4.search(row[filenameIdx]):
            if not row[filenameIdx].strip() == '':
                if row[filenameIdx] in pict_dict:
                    print("ERROR: filename {} appears multiple times in the pictures CSV. Please fix!".format(row[0]))
                else:
                    num_pics = num_pics + 1
                if row[collectionIdx] not in collections:
                    collections.append(row[collectionIdx])
                pict_dict[row[0]] = row


# Read the PiccyBank which is assumed to be a directory of subcollections.
# We assume that all pictures are jpegs which will match '*.jp*'
# TODO: Change to fixed max size, which might be 512, but check with the Mac screen.
# This is done with resize "x512"
max_image_width = 720
max_image_height = 480

resize_dims = str(max_image_width) + 'x' + str(max_image_height) + '>'
jpeg_quality = 92
processed_pics = 0
pcrop = re.compile('^crop\(([0-9]+);([0-9]+);([0-9]+);([0-9]+)\)')

parent = pathlib.Path(__file__).resolve().parent
autotrim_path = str(parent.joinpath('autotrim'))
autotone_path = str(parent.joinpath('autotone'))
# convert (imagemagick) is assumed on path

for collection in collections:
    print("Processing {}".format(collection))
    path = os.path.join(piccybank, collection)
    orig_path = os.path.join(piccybank, collection, originals)
    origlist = pathlib.Path(orig_path).glob('*.jp*')
    for file in origlist:
        filename = file.name
        output_filename = os.path.join(piccybank, collection, filename)
        print('{}  -->  {}'.format(file, output_filename))
        if filename not in pict_dict:
            print("ERROR: file {} does not appear in the pictures CSV.".format(filename))
        filepath = str(file)
        imageProcessing = { x for x in pict_dict[filename][processingIdx].strip().split(',') }

        current_file = filepath
        for item in imageProcessing:
            match = pcrop.match(item)
            if match:
                lefttop = '+' + match.group(1) + '+' + match.group(2)
                rightbottom = '-' + match.group(3) + '-' + match.group(4)
                completed = subprocess.run(['convert', current_file, '-crop', lefttop, '+repage', '-crop', rightbottom,
                                                    'xyzzy3.jpg'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                # print(completed.stdout)
                if completed.stderr != b'':
                    print(completed.stderr)
                current_file = 'xyzzy3.jpg'
        if "trim" in imageProcessing:
            completed = subprocess.run([autotrim_path, '-f', '12', filepath, 'xyzzy1.jpg'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            # print(completed.stdout)
            if completed.stderr != b'':
                print(completed.stderr)
            current_file = 'xyzzy1.jpg'
        if "autotone" in imageProcessing:
            completed = subprocess.run([autotone_path, '-n', '-s', current_file, 'xyzzy2.jpg'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            # print(completed.stdout)
            if completed.stderr != b'':
                print(completed.stderr)
            current_file = 'xyzzy2.jpg'
        copyright = pict_dict[filename][creditsIdx].strip()
        if copyright != '':
            # print(copyright)
            # Put non-breaking space around copyright
            copyright = '  ' + copyright + '  '
            # Insert newlines if too long. This is still super-heuristic. Should really get picture size and font metrics....
            if len(copyright) > 38:
                place = copyright.find(' ', 30)
                if place == -1:
                    place = copyright.find(' ', 22)
                    if place == -1:
                        place = copyright.find(' ', 14)
                if place >= 0:
                    copyright = copyright[0:place] + '  \n  ' + copyright[place+1:]
            completed = subprocess.run(['convert', current_file, '-colorspace', 'RGB', '-resize', resize_dims,
                                        '-colorspace', 'sRGB', '-fill', 'white', '-undercolor', '#00000060', '-font', font,
                                        '-pointsize', '18', '-gravity', 'SouthWest', '-annotate', '+0+3', copyright,
                                        '-quality', str(jpeg_quality), output_filename], 
                                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        else:
            with Image.open(current_file) as im:
                width, height = im.size            
            if width > max_image_width or height > max_image_height:
                completed = subprocess.run(['convert', current_file, '-colorspace', 'RGB', '-resize', resize_dims,
                                                '-colorspace', 'sRGB', '-quality', str(jpeg_quality), 
                                                output_filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            else:
                completed = subprocess.run(['convert', current_file, '-quality', str(jpeg_quality),
                                            output_filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        # print(completed.stdout)
        if completed.stderr != b'':
            print(completed.stderr)
        processed_pics = processed_pics + 1
        # Delete as used (will error if try to use twice, though should have been detected earlier)
        del pict_dict[filename]

subprocess.run(['rm', '-f', 'xyzzy1.jpg', 'xyzzy2.jpg', 'xyzzy3.jpg'])

# Print stats
print("CSV file {} has {} pictures; found and reformatted {} pictures in {} collections.".format(
    pictures_db, num_pics, processed_pics, len(collections)))
if len(pict_dict) > 0:
    print("Pictures from CSV not found in filepath: {}".format(list(pict_dict.keys())))
