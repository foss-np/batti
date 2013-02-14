#!/bin/sh

#first download a fresh file
#bash ./downloader.sh

#convert blah.blah.pdf to .txt and to unicode
bash ./convertor.sh

#extract out the schedule
bash ./extract.sh
