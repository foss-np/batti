#!/bin/bash

set -e

WD="$(dirname $(readlink $0 || echo $0))"
SCHEDULE="$HOME/.cache/batti.sch"
TEMP='/tmp'

function download {
    wget -c http://nea.org.np/loadshedding.html -O $TEMP/nea.html
    link=($(sed -n '/supportive_docs/p' $TEMP/nea.html |\
            tr '<' '\n' | sed -n 's/.*\(http.*pdf\)">.*/\1/gp'))
    wget -c ${link[0]} -O $TEMP/nea.pdf
}

function extract {
    [ -e $SCHEDULE ] && hash_old=$(md5sum $SCHEDULE)
    rm -f $SCHEDULE
    pdftotext -f 1 -layout $TEMP/nea.pdf $TEMP/raw.txt
    sed -n '/;d"x÷af/,/;d"x–@/p' $TEMP/raw.txt > $TEMP/part.txt
    sed -i 's/\;d"x–.//; /M/!d; s/^ \+//' $TEMP/part.txt
    # NOTE: 2utf8 is not-really required but for fail and debug situations
    # 2utf8 -i $TEMP/part.txt > $TEMP/uni.txt
    # sed -i 's/०/0/g; s/१/1/g; s/२/2/g; s/३/3/g;
    #         s/४/4/g; s/५/5/g; s/६/6/g; s/७/7/g;
    #         s/८/8/g; s/९/9/g; s/–/-/g;' $TEMP/uni.txt
    sed -i 's/)/0/g; s/!/1/g; s/@/2/g; s/#/3/g;
            s/%/5/g; s/\^/6/g; s/\&/7/g;
            s/\*/8/g; s/(/9/g; s/–/-/g; s/M/:/g' $TEMP/part.txt
    # FIX: its hard to replace $
    cat $TEMP/part.txt | tr '$' '4' > $TEMP/uni.txt

    sed 's/ \+/\t/g' $TEMP/uni.txt | head -2 > $SCHEDULE

    hash_new=$(md5sum $SCHEDULE)
    >&2 echo "> Schedule Extracted"
    if [[ "$hash_new" == "$hash_old" ]]; then
        >&2 echo "> Schedule Unchanged"
    else
        >&2 echo "> New Schedule"
    fi
}

function get_color { # arg($1:color_code)
    # NOTE: cdef is always same
    [[ "$SGR" = "" ]] && echo "\033[$1;$2m"
}

function rotate_field { # arg($1:day, $2:group)
    f=$(($1-$2))
    [ $f -le 0 ] && f=$((7+$f))
    echo $f
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
    data=($(cat $SCHEDULE))
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
                echo -en "$c2${data[f0]} "
                line2+=$(echo -en "$c2${data[f1]} ")
            fi
        }
        echo -e "$cdef\n          $line2"
    }
}

function today_view { # arg($1:group)
    field=$(rotate_field $today $1)
    f0=$((field-1))
    f1=$((f0+7))
    echo ${data[f0]}, ${data[f1]}
}

function update {
    local FILE="$TEMP/nea.pdf"
    [ -e $FILE ] || download
    [ -e $FILE ] && extract
}

[ -e $SCHEDULE ] || update

#checking arguments
if [ $# -eq 0 ]; then
    all_sch
    exit 0;
fi

function Credits {
    h1=$(get_color 1 32)
    cdef=$(get_color 0 0)
    sed 's/^#.*/'`echo -e $h1`'&'`echo -e $cdef`'/' $WD/AUTHORS
    echo
}

function Usage {
    cat << EOF
    Usage: $PROGNAME [options] [group_no]
    
    This is an utility script written while I was learning Shell Scipting. 
    
    Motivation: जहिले  बत्ती कति बजे अाउला भनेर भित्तामा टासेको रुटिन हेर्नु पर्ने, खल्तीको मोवाई जिकेर हेर्नु पर्ने, लास्टै अल्छि लाग्यो |  
    
    Gist: This utiltity fetch pdf Nepal Electricity Authority (NEA) provides and process and filter schedule as options provided.

    OPTIONS:
       -a --all                 Show All schedules [force]
       -g --group               Group Number to watch schedule for.
       -t --today               Show today's schedule [uses with group no]
       -w --week                Show week's schedule
       -u --update              Check for updates on routine

      Dump Variation:
       -d --dump                Schedule raw dump
       -x --xml                 Dump to xml
       
      Extra:
       -c --credits             Display the credits
       -h --help                Show this help message
       -v --version             Version Information
    
    Examples:
       Show schedule for group 3
       $PROGNAME -g3 

       Show today's schedule for group4
       $PROGNAME --group 4 --today

EOF
}

GETOPT=$(getopt -o g:awtudxchv\
              -l all,group:,week,today,update,dump,xml,credits,help,version\
              -n "batti"\
              -- "$@")

eval set -- "$GETOPT"

dis=0
while true; do
    case $1 in
        -a|--all)        dis=1; shift;;
        -g|--group)      grp=$2; shift 2;;
        -w|--week)       dis=0; shift;;
        -t|--today)      dis=3; shift;;
        -u|--update)     update; exit;;
        -d|--dump)       cat $SCHEDULE; exit;;
        -x|--xml)        xml_dump; exit;;
        -c|--credits)    Credits; exit;;
        -h|--help)       Usage; exit;;
        -v|--version)    cat $WD/.version; exit;;
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
