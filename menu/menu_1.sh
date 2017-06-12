#!/bin/bash

CORES=1
MEM=2

shutDown () {
	echo "bye"
}

helpMe () {
	echo "help notes"
}

runMe () {
	echo "${CORES} CPU Cores"
	echo "${MEM}G of Memory"
}

while getopts hH-h-Hc:C:m:M:xX option
do
	case "${option}"
 	in
	H|h|help) 
		helpMe
		exit 0
		;;
 	C|c) 
		CORES=${OPTARG}
		;;
 	M|m) 
		MEM=${OPTARG}
		;;
 	X|x) 
		shutDown
		exit 0
		;;
 	esac
done

runMe
