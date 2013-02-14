#!/bin/bash
mkdir groups
gpNo="$1"
cat uni.sch|tail -$(((gpNo-1)*2))>./groups/group$gpNo
cat uni.sch|head -$(((7-(gpNo-1))*2))>>./groups/group$gpNo

echo -e "LoadSheeding Schedule: group $gpNo:\n''''''''''''''''''''''''''''''''"
cat groups/group$gpNo
echo ---------------------------------
