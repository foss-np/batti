#!/bin/bash

WD="$(dirname $0)"
PRG="$(basename $0)"

SCHEDULE="$HOME/.cache/batti.sch"

function download {
    wget -c http://nea.org.np/loadshedding.html -O /tmp/nea.html
    link=($(sed -n '/supportive_docs/p' /tmp/nea.html |\
            tr '<' '\n' | sed -n 's/.*\(http.*pdf\)">.*/\1/gp'))
    wget -c ${link[0]} -O /tmp/nea.pdf
}

function extract {
    rm -f $SCHEDULE
    pdftotext -f 1 -layout /tmp/nea.pdf /tmp/raw.txt
    sed -n '/;d"x÷af/,/;d"x–@/p' /tmp/raw.txt > /tmp/part.txt
    sed -i 's/\;d"x–.//; /M/!d; s/^ \+//' /tmp/part.txt
    # NOTE: if u think you will know why its here
    $WD/2utf8/main.sh -f /tmp/part.txt > /tmp/uni.txt
    sed -i 's/०/0/g; s/१/1/g; s/२/2/g; s/३/3/g;
            s/४/4/g; s/५/5/g; s/६/6/g; s/७/7/g;
            s/८/8/g; s/९/9/g; s/–/-/g;' /tmp/uni.txt
    sed 's/ \+/\t/g' /tmp/uni.txt | head -2 > $SCHEDULE
    echo "Schedule Extracted"
    # cat $SCHEDULE
}

function get_color { # arg($1:color_code)
    # NOTE: cdef is always same
    if [ "$SGR" = "" ] ; then
		echo "\033[$1;$2m"
    fi
}

function rotate_field { # arg($1:day, $2:group)
    f=$(($1-$2))
    if [ $f -le 0 ]; then
		echo $((7+$f))
    else
		echo $f
    fi
}

function range_check { # arg($1:check_value)
	if [[ $1 -gt 0 ]] && [[ $1 -le 7 ]]; then
		echo -n # do nothing
	else
		Usage
		exit 1;
	fi
}

function week_view { # arg($1:group)
    day=(Sun Mon Tue Wed Thr Fri Sat)

    for((i=0;i<7;i++)) {
		field=$(rotate_field $i $1)
		f0=$((field-1))
		f1=$((f0+7))

		if [ $today == $i ]; then
			color=$(get_color 1 32)
			cdef=$(get_color 0 0)
		else
			color=""
			cdef=""
		fi

		echo -e ${color}${day[$i]} # $field
		echo -e "\t${data[f0]}"
		echo -e "\t${data[f1]}$cdef"
    }
}

function xml_dump {
    day=(sunday monday tuesday wednesday thursday friday saturday)
    echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<routine>"
    for((g=1;g<=7;g++)) {
		echo -e "    <group name=\"$g\">"
		grp=$(($g-2))
		for((i=0;i<7;i++)) {
			field=$(rotate_field $i $grp)
			f0=$((field-1))
			f1=$((f0+7))

			echo "      <day name=\"${day[$i]}\">"
			echo "        <item>${data[f0]}</item>"
			echo "        <item>${data[f1]}</item>"
			echo "      </day>"
		}
		echo -e "    </group>"
    }
    echo "</routine>"
}

function all_sch { # arg($1:group)
    # is loaded by default so data must be loaded
    data=($(sed 's/://g' $SCHEDULE))

    h1=$(get_color 1 32)
    c1=$(get_color 1 34)
    cdef=$(get_color 0 0)

    echo -en "          $h1"

    for day in Sun Mon Tue Wed Thr Fri Sat ; do
		printf "   %-7s" $day
    done
    echo -en "$cdef\n"

    today=(`date +%w`)
    for((g=1;g<=7;g++)) {
		echo -en "$h1 Group $g: $cdef"
		grp=$(($g-2))
		line2=""
		if [ "$1" == $grp ]; then c2=$(get_color 0 34);
		else c2=""; fi

		for((i=0;i<7;i++)) {
			field=$(rotate_field $i $grp)
			f0=$((field-1))
			f1=$((f0+7))
			if [ $today == $i ]; then
				echo -en "$c1${data[$f0]}$cdef "
				line2+=$(echo -en "$c1${data[f1]}$cdef ")
			else
				echo -en "$c2${data[f0]}$cdef "
				line2+=$(echo -en "$c2${data[f1]}$cdef ")
			fi
		}
		echo -e "\n          $line2"
    }
}

function today_view { # arg($1:group)
    field=$(rotate_field $today $1)
    f0=$((field-1))
    f1=$((f0+7))
    echo ${data[f0]}, ${data[f1]}
}

function update {
    local FILE="/tmp/nea.pdf"
    if [ ! -e $FILE ]; then
		download
    fi
    if [ -e $FILE ]; then
		extract
    fi
}

if [ ! -e $SCHEDULE ]; then
    update
fi

#checking arguments
if [ $# -eq 0 ]; then
    all_sch
    exit 0;
fi

function Usage {
    echo -e "Usage:  batti [OPTIONS] [GROUP_NO]";
    echo -e "\t-a | --all\tShow All [default]"
    echo -e "\t-g | --group\tGroup number 1-7"
    echo -e "\t-t | --today\tShow today's schedule [uses with group no]"
    echo -e "\t-w | --week\tShow week's schedule"
    echo -e "\t-u | --update\tCheck for update [ignores extra options]"
    echo -e "\t-x | --xml\tDump to xml"
    echo -e "\t-h | --help\tDisplay this message"
}

TEMP=$(getopt -o g:awtuxh\
              -l all,group:,week,today,update,xml,help\
              -n "batti"\
              -- "$@")

if [ $? != "0" ]; then exit 1; fi

eval set -- "$TEMP"

dis=0
while true; do
	case $1 in
		-a|--all)        dis=1; shift;;
		-g|--group)      grp=$2; shift 2;;
		-w|--week)       dis=0; shift;;
		-t|--today)      dis=3; shift;;
		-u|--update)     update; exit;;
		-x|--xml)        xml_dump; exit;;
		-h|--help)       Usage; exit;;
		--)              shift; break;;
    esac
done

# extra argument
for arg do
    grp=$arg
    break
done

range_check "$grp"
data=($(cat $SCHEDULE))
grp=$(($grp-2)) # for rotation
today=(`date +%w`)

if   (( "$dis" == 0 )); then week_view $grp
elif (( "$dis" == 1 )); then all_sch $grp
else today_view $grp; fi
