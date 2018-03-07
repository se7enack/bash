#!/bin/bash

size=0

#ssh key
key=/keys/sshkey

swarmips() {
	    docker node ls -q | xargs docker node inspect | grep -E "Addr|Hostname" | grep -A 1 "$1"
}

progress () {
	echo -n ''
	printf "#"
	#printf ${i}
}

clear
echo
echo "Pruning Swarm. Please wait:"
for i in $( swarmips | grep 10. | grep -v :23 | tr -d "\"" | tr -d "Addr: " ); do
	float=$(ssh -o "StrictHostKeyChecking no" -i ${key} docker@$i "docker system prune -af" | \
	grep "reclaimed" | grep "GB" | awk -F':' '{print $2}' | sed 's/GB$//')
	int=${float%.*}
	size=$(($int+$size))
	progress
done

echo -n
echo
echo "Approximately ${size}GB of space has been reclaimed."
echo
