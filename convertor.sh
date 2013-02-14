#!/bin/sh

cd ./tmp/
pdftotext *.pdf 
java -jar FontConverter.jar
cp *unicode.txt uni.txt


