#!/bin/bash

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


if [ ! -e table.sch ]; then
    download
    ./extract.sh
fi

day=(Sun Mon Tue Wed Thr Fri Sat)
time=(`cut -f$1 table.sch`)
today=(`date +%w`)
for((i=0;i<7;i++)) {
    r1=$(($i*2))
    r2=$(($r1+1))
    if [ $today == $i ]; then
	color="\033[1;32m"
	cdef="\033[0m"
    else
	color=""
	cdef=""
    fi

    echo -e ${color}${day[$i]}
    echo -e "\t${time[$r1]}"
    echo -e "\t${time[$r2]}$cdef"
}
    



