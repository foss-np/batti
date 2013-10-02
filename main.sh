#!/bin/bash

WD="$(dirname $0)"
PRG="$(basename $0)"

SCHEDULE="$HOME/.cache/batti.sch"

function Usage {
    echo -e "Usage: \tbatti -g [1-7] [OPTIONS]";
    echo -e "\t-a | --all\tShow All [default]"
    echo -e "\t-g | --group\tGroup number 1-7"
    echo -e "\t-t | --today\tShow today's schedule [uses with group no]"
    echo -e "\t-w | --week\tShow week's schedule"
    echo -e "\t-u | --update\tCheck for update [ignores extra options]"
    echo -e "\t-s | --sparrow\tCheck for update from loadshedding.sparrowsms.com"
    echo -e "\t-x | --xml\tDump to xml"
    echo -e "\t-h | --help\tDisplay this message"
    exit
}

function download {
    wget -c http://nea.org.np/loadshedding.html -O /tmp/nea.html
    link=$(egrep -o "http.*pdf" /tmp/nea.html)
    wget -c $link -O /tmp/nea.pdf
}

function getall { #all schedule
    pdftotext -layout /tmp/nea.pdf /tmp/raw.txt
    sed -n '/;d"x÷af/,/;d"x–@/p' /tmp/raw.txt > /tmp/part.txt
    sed -i 's/\;d"x–.//; /M/!d; s/^ \+//' /tmp/part.txt
    $WD/2utf8/main.sh -f /tmp/part.txt > /tmp/uni.txt
    replace
    sed 's/ \+/\t/g' /tmp/uni.txt | head -2 > $SCHEDULE
}

function replace {
    sed -i 's/०/0/g; s/१/1/g; s/२/2/g; s/३/3/g;
            s/४/4/g; s/५/5/g; s/६/6/g; s/७/7/g;
            s/८/8/g; s/९/9/g' /tmp/uni.txt
}

function extract {
    rm -f $SCHEDULE
    getall
    replace
    cat $SCHEDULE
}

function week_view {
    day=(Sun Mon Tue Wed Thr Fri Sat)

    for((i=0;i<7;i++)) {
	field=$(($i-$grp))
	if [ $field -le 0 ]; then
	    field=$((7+$field))
	fi

	if [ $today == $i ] && [ "$SGR" = "" ] ; then
	    color="\033[1;32m"
	    cdef="\033[0m"
	else
	    color=""
	    cdef=""
	fi

	echo -e ${color}${day[$i]} #$field
	time=($(cut -f$field $SCHEDULE))
	echo -e "\t${time[0]}"
	echo -e "\t${time[1]}$cdef"
    }
}

function xml_dump {
    day=(sunday monday tuesday wednesday thursday friday saturday)
    echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<routine>"
    for((g=1;g<=7;g++)) {
	echo -e "    <group name=\"$g\">"
	grp=$(($g-2))
	for((i=0;i<7;i++)) {
	    field=$(($i-$grp))
	    if [ $field -le 0 ]; then
		field=$((7+$field))
	    fi

	    time=($(cut -f$field $SCHEDULE))

	    echo "      <day name=\"${day[$i]}\">"
	    echo "        <item>${time[0]}</item>"
	    echo "        <item>${time[1]}</item>"
	    echo "      </day>"
	}
	echo -e "    </group>"
    }
    echo "</routine>"
}

function all_sch {
    if [ "$SGR" = "" ] ; then
	color="\033[1;32m"
	cdef="\033[0m"
    else
	color=""
	cdef=""
    fi

    sed 's/://g' $SCHEDULE > /tmp/batti.sch
    SCHEDULE=/tmp/batti.sch

    echo -en "          $color"

    for day in Sun Mon Tue Wed Thr Fri Sat ; do
	printf "   %-7s" "$day"
    done
    echo

    today=(`date +%w`)
    for((g=1;g<=7;g++)) {
	echo -en $color" Group $g: "$cdef
	grp=$(($g-2))
	for((i=0;i<7;i++)) {
	    field=$(($i-$grp))
	    if [ $field -le 0 ]; then
		field=$((7+$field))
	    fi

	    time=($(cut -f$field $SCHEDULE))

	    if [ $today == $i ] && [ "$SGR" = "" ] ; then
		color2="\033[1;34m"
		cdef2="\033[0m"
	    else
		color2=""
		cdef2=""
	    fi

	    echo -en "$color2${time[0]}$cdef2 "
	}
	echo -n "          "
	for((i=0;i<7;i++)) {
	    field=$(($i-$grp))
	    if [ $field -le 0 ]; then
		field=$((7+$field))
	    fi

	    time=($(cut -f$field $SCHEDULE))

	    if [ $today == $i ] && [ "$SGR" = "" ] ; then
		color2="\033[1;34m"
		cdef2="\033[0m"
	    else
		color2=""
		cdef2=""
	    fi

	    echo -en "$color2${time[1]}$cdef2 "
	}
	echo
    }
}

function today_view {
    field=$(($today-$grp))
    if [ $field -le 0 ]; then
	field=$((7+$field))
    fi
    time=($(cut -f$field $SCHEDULE))
    echo ${time[0]}, ${time[1]}
}

function update {
    if [ ! -e /tmp/nea.pdf ]; then
	download
    fi
    if [ -e /tmp/nea.pdf ]; then
	extract
    fi
}

function sparrow_update {
    #for group 1
     routine=$(curl -s http://loadshedding.sparrowsms.com |grep -Eo '<td>.*</td>'|sed -e's/Group - 2.*//g' -e 's/<[^>]\+>/ /g')
     echo $routine |sed 's/.*SUN *\(.*\),.*MON *\(.*\),.*TUE *\(.*\),.*WED *\(.*\),.*THU *\(.*\),.*FRI *\(.*\),.*SAT  *\(.*\),.*/\1\t\2\t\3\t\4\t\5\t\6\t\7/p' -n > $SCHEDULE
     echo $routine| sed 's/.*SUN.*, *\(.*\) *MON.*, *\(.*\) *TUE.*, *\(.*\) *WED.*, *\(.*\) *THU.*, *\(.*\) *FRI.*, *\(.*\) *SAT.*, *\(.*\).*/\1\t\2\t\3\t\4\t\5\t\6\t\7/p' -n >> $SCHEDULE
}

if [ ! -e $SCHEDULE ]; then
    update
fi

today=(`date +%w`)

#checking arguments
if [ $# -eq 0 ]; then
    all_sch
    exit 1;
fi

TEMP=$(getopt  -o    g:awtuxhs\
              --long all,group:,week,today,update,xml,help,sparrow\
               -n    "batti" -- "$@")

if [ $? != "0" ]; then exit 1; fi

eval set -- "$TEMP"

dis=0 grp=0
while true; do
    case $1 in
	-a|--all) all_sch; exit;;
	-g|--group) grp=$2; shift 2;;
 	-w|--week) dis=0; shift;;
	-t|--today) dis=1; shift;;
	-u|--update) update; exit;;
	-s|--sparrow) sparrow_update; exit;;
	-x|--xml) xml_dump; exit;;
 	-h|--help) Usage; exit;;
	--) shift; break;;
    esac

done

if [ $grp == 0 ]; then Usage; fi
grp=$(($grp-2))
if [ $dis == "0" ]; then week_view;
else today_view; fi
