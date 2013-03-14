#!/bin/bash

PRG=$(basename $0)
source "./path.config"
if [ $? != "0" ]; then
    echo "Error: 2utf8 path not configured"
    exit
fi

function getall { #all schedule
    pdftotext /tmp/nea.pdf /tmp/raw.txt    
    sed -n '/;d"x÷af/,/cTolws/p' /tmp/raw.txt > /tmp/part.txt
    $_2utf8/main.sh -f /tmp/part.txt > /tmp/uni.txt
    sed -i '/2utf8/d' /tmp/uni.txt
}
	    
function maketable {
    sed '/समूह/d; /बुधबार/q' /tmp/uni.txt > /tmp/table.txt
    awk -F ' ' '/[०-९] / { print $1 }' /tmp/uni.txt >> /tmp/table.txt
    echo -e "\nबिहीबार" >> /tmp/table.txt
    awk -F ' ' '/[०-९] / { print $2 }' /tmp/uni.txt >> /tmp/table.txt
    echo -e "\nशुक्रबार" >> /tmp/table.txt
    awk -F ' ' '/[०-९] / { print $3 }' /tmp/uni.txt >> /tmp/table.txt
    echo >> /tmp/table.txt
    sed -n '/शनिबार/,+14p' /tmp/uni.txt >> /tmp/table.txt

    flag=-1
    while read i; do
    	if [ "$i" == "" ]; then
    	    echo -e $row1 >> table.sch
    	    echo -e $row2 >> table.sch	    
    	    row1=""
	    row2=""
	    flag=-1
    	    continue
	fi
	    
	if [ $flag == 0 ]; then
	    row1="$row1$i\t"
	    flag=1
	elif [ $flag == 1 ]; then
	    row2="$row2$i\t"
	    flag=0
	else
	    flag=0
	fi	
    done < /tmp/table.txt
    echo -e $row1 >> table.sch
    echo -e $row2 >> table.sch
}

function replace {
    sed -i 's/०/0/g; s/१/1/g; s/२/2/g; s/३/3/g;
            s/४/4/g; s/५/5/g; s/६/6/g; s/७/7/g;
            s/८/8/g; s/९/9/g; /^$/d' table.sch  
}

rm *.sch -f
getall
maketable
replace
echo "load shedding schedule table:"
cat table.sch
