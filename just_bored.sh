#!/bin/bash

#RE: https://q4interview.com/aptitude-ques-ans-discussion.php?qid=4416&t=70&qnum=346&cat=29

counter=7
count=0
a=1
b=${a}
c=2

fun() {
	echo $a
	count=$(($count+1))
	echo $b
	a=$(($a*$b+$count))
	echo $a
	count=$(($count+1))
	while [ ${counter} -gt 1 ]; do
		b=$(($a))
		a=$(($a*$b+$count))
		echo $(($a-$c))
		c=$(($c+1))
		echo $a
		count=$(($count+1))
		counter=$(($counter-1))
	done
}

fun
     
