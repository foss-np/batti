#!/bin/sh
cd ./tmp/
rm *.txt
pdftotext *.pdf 
java -jar FontConverter.jar
cp *unicode.txt uni.txt


