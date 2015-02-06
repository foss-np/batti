#!/bin/bash

WD="$(dirname $(readlink $0 || echo $0))"

[ -e $WD/path.config ] && source $WD/path.config

function Usage {
    echo -e "Usage: ./conky_forever.sh [GROUP_NO] [/path/to/conky-forever]";
    echo -e "\tGROUP_NO\tgroup number [1-7]"
}

# checking arguments
if [ $# -eq 0 ]; then
    Usage;
    exit 1;
fi

if [ "$2" != "" ]; then
    PATH_conky_forever=$2
    echo "PATH_conky_forever='$2'" > $WD/path.config
fi


PATH_cbatti=$PATH_conky_forever/conkyrc/cbatti

rm -rf $PATH_cbatti
mkdir $PATH_cbatti -p

cp $PATH_conky_forever/sample/main.rc  $PATH_cbatti/main.rc

sed -i 's/\(alignment\).*/\1 top_right/
        s/\(gap_x\).*/\1 70/
       ' $PATH_cbatti/main.rc

echo -e "\n\${color 88aaff}Group $1: \\" >> $PATH_cbatti/main.rc
echo "\${exec $PWD/main.sh -g $1 -t}" >> $PATH_cbatti/main.rc

killall conky
bash $PATH_conky_forever/rconky
