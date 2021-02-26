#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo
	echo "Please run as sudo. I.e.:"
	echo "sudo ${0}"
	echo
	exit
fi
echo "Please remove sd card if already inserted"
sleep 3
read -p "Are you ready? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	ls /dev/disk* | sort > /tmp/without
	echo "Now insert the SD card"
	sleep 3
	read -p "Are you ready? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		ls /dev/disk* | sort > /tmp/with
		sleep 10
		disk=$(diff /tmp/with /tmp/without | grep -m 1 disk | awk '{print $2}')
		disknum=$(echo ${disk} | tr -dc '0-9')
		diskutil unmountDisk ${disk} &> /dev/null
		if [ $? -eq 0 ]; then
			echo "Imaging SD. This will take some time..."
			dd if=${1} of=/dev/rdisk${disknum} bs=1m
			echo "Copy Completed!"
			diskutil eject ${disk}
		else
			echo "ERROR"
		fi	
	else
		echo "Aborted"
	fi	
else
	echo "Aborted"
fi
