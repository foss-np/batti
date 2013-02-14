#!/bin/bash

 
function filter.d(){
sed -n '/^शनिबार/,+2p' ./tmp/uni.txt|tail -2 >sch_nepali.sch
sed -n '/^आईतबार/,+2p' ./tmp/uni.txt|tail -2>>sch_nepali.sch
sed -n '/^सोमबार/,+2p'  ./tmp/uni.txt|tail -2>>sch_nepali.sch
sed -n '/^मंगलबार/,+2p' ./tmp/uni.txt|tail -2>>sch_nepali.sch
sed -n '/^बुधबार/,+2p'  ./tmp/uni.txt|tail -2>>sch_nepali.sch
sed -n '/^बिहीबार/,+3p' ./tmp/uni.txt|tail -2|cut -f1 -d' '>>sch_nepali.sch
sed -n '/^शुक्रबार/,+2p' ./tmp/uni.txt|tail -2|cut -f2 -d' '>>sch_nepali.sch
 
}

function replace(){
    sed -i 's/०/0/g' sch_nepali.sch;
    sed -i 's/१/1/g' sch_nepali.sch;
    sed -i 's/२/2/g' sch_nepali.sch;
    sed -i 's/३/3/g' sch_nepali.sch;
    sed -i 's/४/4/g' sch_nepali.sch;
    sed -i 's/५/5/g' sch_nepali.sch;
    sed -i 's/६/6/g' sch_nepali.sch;
    sed -i 's/७/7/g' sch_nepali.sch;
    sed -i 's/८/8/g' sch_nepali.sch;
    sed -i 's/९/9/g' sch_nepali.sch;
  
    #replace (१४ः००य्.147२०ः००) haru ko {ः with ':'} and {य्.147 with '-'}
    sed -i -e 's/य्.147/-/g' -e 's/ः/:/g' sch_nepali.sch 
}


#program flow
rm *.sch
filter.d
replace
echo -e 'load shedding schedule from [sat-fri] is:\n-----------------------------------------'
cat sch_nepali.sch



#function ask_schedule {
##    case $(date|cut -d' ' -f1) in
#   case "$day" in
#	'sat'|'Sat')  sed -n '/^शनिबार/,+2p' ./tmp/uni.txt;;
#	'sun'|'Sun') sed -n '/^आईतबार/,+2p' ./tmp/uni.txt;;
#	'mon'|'Mon')  sed -n '/^सोमबार/,+2p'  ./tmp/uni.txt;;
#	'tue'|'Tue')  sed -n '/^मंगलबार/,+2p' ./tmp/uni.txt;;
#	'wed'|'Wed')  sed -n '/^बुधबार/,+2p'  ./tmp/uni.txt;;
#	'thur'|'Thur')sed -n '/^बिहीबार/,+3p' ./tmp/uni.txt|tail -2|cut -f1 -d' ';;
#	'fri'|'Fri') sed -n '/^शुक्रबार/,+2p' ./tmp/uni.txt|tail -2|cut -f2 -d' ';;
#	*) echo  "INVALID DAY IN A WEEK";;
#    esac	
#}


#function main(){
#for in_nepali in cat sch_nepali.txt; do
#    IFS="" #don't ignore spaces
#    
#   for ((i=${#in_nepali}; i >= 0; i--)); do    
#	num=${in_nepali:$i:1}
#	nepali2Num
##	echo $num > file$i.tmp
#    done
#   echo
#done
#}


