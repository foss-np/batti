#!/bin/bash

PRG=$(basename $0)
WD="$(dirname $0)"

source "./path.config"
if [ $? != "0" ]; then
    echo "Error: conky-forever path not configured"
    exit
fi

function Usage {
    echo -e "Usage: \t$PRG GROUP_NO";
    echo -e "\tGROUP_NO\tgroup number 1-7"
}

# checking arguments
if [ $# -eq 0 ]; then
    Usage;
    exit 1;
fi

_cbatti=$_conky_forever/conkyrc/cbatti
rm -rf $_cbatti
mkdir $_cbatti -p
cp $_conky_forever/sample/main.rc  $_cbatti/main.rc
sed -i 's/\(alignment\).*/\1 top_right/
        s/\(gap_x\).*/\1 70/
       ' $_cbatti/main.rc

echo -e "\n\${color 88aaff}Group $1: \\" >> $_cbatti/main.rc
echo "\${exec $PWD/main.sh -g $1 -t}" >> $_cbatti/main.rc
killall conky
$_conky_forever/run.sh
