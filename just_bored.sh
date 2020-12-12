#!/bin/bash

#RE: https://q4interview.com/aptitude-ques-ans-discussion.php?qid=4416&t=70&qnum=346&cat=29#

count=1
re='^[0-9]+$'
x=0

fun() {
	echo $x
	y=$(( ${x}+1 ))
	echo $y
	y=$(( ${y}*${y}+$count ))
	echo $y
	if ! [[ 7 =~ ${re} ]] && [[ 7 > 9 ]]; then
   		echo -e "\nThis excepts integers only between 3-9" 
   		echo -e "Example: ${0} [3-9]\n" >&2; exit 1
	fi	
	while [ ${count} -lt 7 ]; do
		count=$(( count+1 ))
		y=$(( ${y}*${y}+$count ))
		echo $y
	done
}

fun
    
