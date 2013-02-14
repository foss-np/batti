#!/bin/sh

#clean every things first, if there exist any old ones.
rm loadshedding* -R
rm *.pdf

mkdir tmp
cd tmp
#first download the loadshedding.html from nea.org.np
wget http://nea.org.np/loadshedding.html

#grep the link to a pdf file
cat loadshedding.html | egrep -o "(http(s)?://){1}[^'\"]+pdf" > link
echo "okey, link "`cat link`" found"

#then get fresh one 
wget `cat link`
echo 'pdf file downloaded... :D'





