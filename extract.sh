#!/bin/bash
 
function filter.d(){
    sed -n '/^आईतबार/,+2p' /tmp/uni.txt|tail -2>uni.sch
    sed -n '/^सोमबार/,+2p' /tmp/uni.txt|tail -2>>uni.sch
    sed -n '/^मंगलबार/,+2p' /tmp/uni.txt|tail -2>>uni.sch
    sed -n '/^बुधबार/,+4p' /tmp/uni.txt|tail -2|cut -f1 -d' '>>uni.sch
    sed -n '/^बिहीबार/,+3p' /tmp/uni.txt|tail -2|cut -f2 -d' '>>uni.sch
    sed -n '/^शुक्रबार/,+2p' /tmp/uni.txt|tail -2|cut -f3 -d' '>>uni.sch
    sed -n '/^शनिबार/,+2p' /tmp/uni.txt|tail -2 >>uni.sch 
}

function replace(){
    sed -i 's/०/0/g; s/१/1/g; s/२/2/g; s/३/3/g;
            s/४/4/g; s/५/5/g; s/६/6/g; s/७/7/g;
            s/८/8/g; s/९/9/g;' uni.sch
  
    #replace (१४ः००य्.147२०ः००) haru ko {ः with ':'} and {य्.147 with '-'}
    #sed -i -e 's/य्.147/-/g' -e 's/ः/:/g' -e 's/:00//g' uni.sch    
}


rm *.sch -f
filter.d
replace
echo -e 'load shedding schedule from [sat-fri] is:\n'
cat uni.sch
