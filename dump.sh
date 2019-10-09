#!/bin/bash
set -e

##################################################################################################################
# Edit the following vars

# String in/of container name
NOM="iajq3x0c43qc"

# Date
DATE="080919"

# Lowercase "us1", "us2", or "us3"
ENV="us1"

USER="devops"

if [ $ENV = "us1" ]
then
	KEY="~/.ssh/us1-swarm.key"
fi

if [ $ENV = "us2" ]
then
	KEY="/.ssh/us2-swarm.key"
fi

if [ $ENV = "us3" ]
then
	KEY="~/.ssh/us3-swarm.key"
fi

##################################################################################################################

echo "Using the following ssh key to connect to the swarm: " $KEY
echo
echo "Getting Node IP..."
IP=$(docker node inspect  $(./${ENV}.sh ps| grep $NOM  | awk '{ print $4 }') | grep Addr | awk -F'"' '{print $4}')
echo "IP: " $IP
echo
echo "Getting Container ID..."
CID=$(ssh -i ${KEY} $USER@$IP docker ps | grep -v CONTAINER | awk '{ print $1 }')
echo "Container ID: " $CID
echo
echo "Getting Java PID..."
JPID=$(ssh -i ${KEY} $USER@$IP docker exec -i $CID ps aux |grep -i java | grep root | awk '{ print $2 }')
echo "Java Process ID: " $JPID
echo
echo "Creating Dump Of Aforementioned JPID..."
ssh -i ${KEY} $USER@$IP docker exec -i $CID jmap -dump:file=/tmp/${DATE}_DumpFile.hprof $JPID
echo
echo "Copying Dump Up To Host From The Container..."
echo
echo
echo "If prompted provide your local password...."
sudo ssh -i ${KEY} $USER@$IP docker cp $CID:/tmp/${DATE}_DumpFile.hprof /tmp/.
echo
echo "Tarring The Dump Up..."
ssh -i ${KEY} $USER@$IP "cd /tmp;tar -czvf ${DATE}_DumpFile.hprof.tar.gz ${DATE}_DumpFile.hprof"
echo
echo "Removing Uncompressed Copy From Container..."
ssh -i ${KEY} $USER@$IP "docker exec -i $CID rm /tmp/${DATE}_DumpFile.hprof"
echo
echo "SCP-ing Compressed Copy To Your Local Desktop..."
echo
cd ~/Desktop; scp -i ${KEY} $USER@$IP:/tmp/${DATE}_DumpFile.hprof.tar.gz .
echo
echo "Removing Compressed and Uncompressed Copies From Host..."
ssh -i ${KEY} $USER@$IP "rm -f /tmp/${DATE}_DumpFile.*"
echo done; echo
