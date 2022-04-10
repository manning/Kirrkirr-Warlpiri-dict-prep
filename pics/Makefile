copycurrent: Warlpiri-pictures.csv
	cp Warlpiri-pictures.csv Warlpiri-pictures.csv.bak
	java edu.stanford.nlp.misc.LineEndings -fix Warlpiri-pictures.csv
	cp Warlpiri-pictures.csv /Users/manning/Kirrkirr/PiccyBank/
	cp Warlpiri-pictures.csv /Users/manning/Dropbox/Warlpiri2018/
	cp Makefile-PiccyBank /Users/manning/Kirrkirr/PiccyBank/Makefile

testimages: Warlpiri-pictures.csv ../data/wrl-proc/newWrl.xml
	python incorp-pics.py Warlpiri-pictures.csv ../data/wrl-proc/newWrl.xml foo.xml "/Users/manning/Kirrkirr/WarlpiriKirrkirr/Kirrkirr404/Kirrkirr 4.0.4 Warlpiri/Warlpiri2018/images"

kirrkirr-images:
	python prepare-pics.py /Users/manning/Kirrkirr/PiccyBank/Warlpiri-pictures.csv  /Users/manning/Kirrkirr/PiccyBank
