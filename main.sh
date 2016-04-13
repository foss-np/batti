#!/bin/bash

set -e

WD="$(dirname $(readlink $0 || echo $0))"
SCHEDULE="${HOME}/.cache/batti.sch"
TEMP='/tmp'
days=(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
today=(`date +%w`)

function download {
    wget -c http://nea.org.np/loadshedding.html -O $TEMP/nea.html
    links=($(sed -n '/supportive_docs/p' $TEMP/nea.html |\
                   tr '<' '\n' | sed -n 's/.*\(http.*pdf\)">.*/\1/p'))
    first_one=$(echo $links | sed -n '1p')
    wget -c "${first_one}" -O $TEMP/nea.pdf
}

function extract {
    [[ -e $SCHEDULE ]] && hash_old=$(md5sum $SCHEDULE | cut -b 1-32)

    pdftotext -f 1 -layout $TEMP/nea.pdf $TEMP/raw.txt
    sed -n '/;d"x÷af/,/;d"x–@/p' $TEMP/raw.txt | sed '2,${/;d"x÷af/q}' > $TEMP/part.txt

    # NOTE: 2utf8 is not-really required but for fail and debug situations
    # 2utf8 -i $TEMP/part.txt > $TEMP/uni2.txt

    #
    ## BEGIN: 2utf8
    sed -i 's/)/0/g; s/!/1/g; s/@/2/g; s/#/3/g;
            s/%/5/g; s/\^/6/g; s/\&/7/g;
            s/\*/8/g; s/(/9/g; s/–/-/g; s/M/:/g' $TEMP/part.txt
    cat $TEMP/part.txt | tr '$' '4' > $TEMP/uni.txt # FIX: its hard to replace $
    ## END: 2utf8

    ## screw it, you are drunk nea
    $WD/main.py $TEMP/uni.txt | sed -n '/[0-9]/p' > $TEMP/batti.sch

    hash_new=$(md5sum $TEMP/batti.sch | cut -b 1-32)
    if [[ "$hash_new" == "$hash_old" ]]; then
        >&2 echo "> Schedule Unchanged"
    else
        >&2 echo "> New Schedule"
        mkdir -p $(dirname $SCHEDULE)
        mv $SCHEDULE ${SCHEDULE/.sch/.bak}
        cp $TEMP/batti.sch $SCHEDULE
    fi
}

function get_color { # arg($1:color_code)
    # NOTE: cdef is always same
    [[ -z "$SGR" ]] && echo "\033[$1;$2m"
}

function rotate_field { # arg($1:day, $2:group)
    f=$(($1-$2))
    [[ $f -le 0 ]] && f=$((7+$f))
    echo $f
}

function range_check { # arg($1:check_value)
    if [[ -z $1 ]]; then
        echo -n
    elif [[ $1 -gt 0 ]] && [[ $1 -le 7 ]]; then
        echo -n $(($grp-2)) # subtract for rotation because of data
    else
        >&2 echo "group number out of range"
        exit 1
    fi
}

function view_today { # arg($1:group)
    field=$(rotate_field $today $1)
    f0=$((field-1))
    f1=$((f0+7))
    f2=$((f0+14))
    echo -n "${data[f0]}, ${data[f1]}"
    [[ -z "${data[f2]}" ]] || echo -n ", ${data[f2]}" && echo
}

function view_week { # arg($1:group)
    for((i=0; i<7; i++)) {
        field=$(rotate_field $i $1)
        f0=$((field-1))
        f1=$((f0+7))
        f2=$((f0+14))

        if [[ $today == $i ]]; then
            color=$(get_color 1 32)
            cdef=$(get_color 0 0)
        else
            color=""
            cdef=""
        fi

        echo -e "${color}${days[$i]:0:3}" # $field
        echo -e "\t${data[f0]}"
        echo -e "\t${data[f1]}\n";
        [[ -z "${data[f2]}" ]] || echo -ne "\n\t${data[f2]}$cdef" && echo -e "$cdef"
    }
}

function view_all { # arg($1:group)
    # is loaded by default so data must be loaded
    data=($(sed 's/://g' $SCHEDULE))

    h1=$(get_color 1 32)
    c1=$(get_color 1 34)
    cdef=$(get_color 0 0)

    echo -en "          $h1"

    for day in ${days[@]}; do
        printf "   %-7s" ${day:0:3}
    done
    echo -e "$cdef"

    for((g=1; g<=7; g++)) {
        echo -en "$h1 Group $g: $cdef"
        grp=$(($g-2))
        line2=""
        line3=""
        if [[ "$1" != $grp ]]; then c2=""
        else c2=$(get_color 0 34); fi

        for((i=0; i<7; i++)) {
            field=$(rotate_field $i $grp)
            f0=$((field-1))
            f1=$((f0+7))
            f2=$((f0+14))
            if [[ $today == $i ]]; then
                echo -en "$c1${data[f0]}$cdef "
                line2+=$(echo -en "$c1${data[f1]}$cdef ")
                line3+=$(echo -en "$c1${data[f2]}$cdef ")
            else
                echo -en "$c2${data[f0]} "
                line2+=$(echo -en "$c2${data[f1]} ")
                line3+=$(echo -en "$c2${data[f2]} ")
            fi
        }

        if [[ -z "${data[f2]}" ]]; then
            echo -e "$cdef\n          $line2"
        else
            echo -ne "$cdef\n          $line2"
            echo -e  "$cdef\n          $line3"
        fi
    }
}

function xml_dump {
    data=($(cat $SCHEDULE))
    echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<routine>"
    for((g=1; g<=7; g++)) {
        echo -e "    <group name=\"$g\">"
        grp=$((g-2))
        for((i=0; i<7; i++)) {
            field=$(rotate_field $i $grp)
            f0=$((field-1))
            f1=$((f0+7))
            f2=$((f0+14))

            echo "      <day name=\"${days[$i]}\">"
            echo "        <item>${data[f0]}</item>"
            echo "        <item>${data[f1]}</item>"
            [[ -z "${data[f2]}" ]] || echo "        <item>${data[f2]}</item>"
            echo "      </day>"
        }
        echo "    </group>"
    }
    echo "</routine>"
}

function update {
    local FILE="$TEMP/nea.pdf"
    [[ -e $FILE ]] || download
    if [[ -e $FILE ]]; then
        file $FILE | grep PDF && extract || {
                rm $FILE
                >&2 echo "Error in PDF, run the update again"
            }
    fi
}

function credits {
    h1=$(get_color 1 32)
    cdef=$(get_color 0 0)
    sed 's/^#.*/'`echo -e $h1`'&'`echo -e $cdef`'/' $WD/AUTHORS
    echo
}

function usage {
    echo -e "Usage:  batti [OPTIONS] [GROUP_NO]";
    echo -e "\t-a | --all\tShow All [default]"
    echo -e "\t-w | --week\tShow weeks schedule"
    echo -e "\t-t | --today\tShow todays schedule"
    echo -e "\t-g | --group\tGroup number [1-7]"
    echo -e "\t-u | --update\tCheck for update"
    echo -e "\t-p | --previous\tShow previous schedule"
    echo -e "\t-d | --dump\tDump raw schedule data"
    echo -e "\t-x | --xml\tDump to xml"
    echo -e "\t-c | --credits\tDisplay credits"
    echo -e "\t-h | --help\tDisplay this information"
    echo -e "\t-v | --version\tVersion information"
}

GETOPT=$(getopt -o g:awtupdxchv\
              -l all,group:,week,today,update,previous,dump,xml,credits,help,version\
              -n "batti"\
              -- "$@")

eval set -- "$GETOPT"

view_mode=0
while true; do
    case $1 in
        -a|--all)        view_mode=0; shift;;
        -w|--week)       view_mode=1; shift;;
        -t|--today)      view_mode=2; shift;;
        -g|--group)      grp=$2; shift 2;;
        -u|--update)     update; exit;;
        -p|--previous)   SCHEDULE=${SCHEDULE/.sch/.bak}; shift;;
        -d|--dump)       cat $SCHEDULE; exit;;
        -x|--xml)        xml_dump; exit;;
        -c|--credits)    credits; exit;;
        -h|--help)       usage; exit;;
        -v|--version)    cat $WD/.version; echo; exit;;
        --)              shift; break;;
    esac
done

# extra argument
for arg do
    grp=$arg
    break
done

grp=$(range_check "$grp")

[[ -e $SCHEDULE ]] || update
data=($(cat $SCHEDULE))

if [[ $view_mode != "0" ]] && [[ "$grp" == "" ]]; then
    >&2 echo "group not defined"
    exit 1
fi

if   (( "$view_mode" == 2 )); then view_today $grp
elif (( "$view_mode" == 1 )); then view_week $grp
else view_all $grp; fi
