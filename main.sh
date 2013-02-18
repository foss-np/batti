#!/bin/bash

PRG=$(basename $0)
source "./path.config"
if [ $? != "0" ]; then
    echo "Error: 2utf8 path not configured"
    exit
fi

function Usage {
    echo -e "Usage: \t$PRG GROUP_NO";
    echo -e "\t gpNo --your loadshedding group number...\nEg @ku ko gpNo:7 so type \n ./$PRG 7"
}

# checking arguments
if [ $# -eq 0 ]; then
    Usage;
    exit 1;
fi

function download {
    wget -c http://nea.org.np/loadshedding.html -O /tmp/nea.html
    link=$(egrep -o "http.*pdf" /tmp/nea.html)
    wget -c $link -O /tmp/nea.pdf
}

function 2utf8 {    
    pdftotext /tmp/nea.pdf /tmp/raw.txt    
    $_2utf8/main.sh -f /tmp/raw.txt > /tmp/uni.txt
    cat /tmp/uni.txt
}

download
2utf8
./extract.sh
./feeder.sh $1
