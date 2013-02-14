#!/bin/sh

PRG=$(basename $0)

function Usage {
    echo -e "Usage: \t$PRG gpNo";
    echo -e "\t gpNo --your loadshedding group number...\nEg @ku ko gpNo:7 so type \n ./$PRG 7"
}

# checking arguments
if [ $# -eq 0 ]; then
    Usage;
    exit 1;
fi


#first download a fresh file
bash ./downloader.sh

#convert blah.blah.pdf to .txt and to unicode
bash ./convertor.sh

#extract out the schedule
bash ./extract.sh

#output schedule as desired group number
bash ./feeder.sh $1



