#!/bin/bash


# "This tool will connect up to an Azure 'Resource Group', SSH into each VM running inside of it and pull all of logs off of each of them."
# "* Don't forget to add your SUBSCRIPTIONID below as well as your RESOURCEGROUP names in the menu function."


#For Tomcat use: /apps/tomcat/logs/
#If your path differs change this to match your path:
LOGDIR="/apps/tomcat/logs/"

#Azure Subscription ID
SUBSCRIPTIONID=""

preflightCheck () {
    which -s azure
    if [ $? -ne 0 ]
    then
        echo
        echo "Please install the azure cli to use this tool"
        exit
    fi
    which -s jq
    if [ $? -ne 0 ]
    then
        echo
        echo "Please install the jq package to use this tool"
        exit
    fi
    ls exp &> /dev/null
    if [ $? -ne 0 ]
    then
        expWrap
    fi
}

banner () {
 echo "                                __      ____  __   _                      "                    
 echo "     /\                         \ \    / /  \/  | | |                     "                   
 echo "    /  \    _____   _ _ __ ___   \ \  / /| \  / | | |     ___   __ _ ___  " 
 echo "   / /\ \  |_  / | | | '__/ _ \   \ \/ / | |\/| | | |    / _ \ / _\` / __|"
 echo "  / ____ \  / /| |_| | | |  __/    \  /  | |  | | | |___| (_) | (_| \__ \ "
 echo " /_/    \_\/___|\__,_|_|  \___|     \/   |_|  |_| |______\___/ \__, |___/ "
 echo "                                                               __/ |      "    
 echo "                                                              |___/       "
}

expWrap () {
    echo "#!/usr/bin/expect" > ./exp
    echo "" >> ./exp
    echo "set timeout 5" >> ./exp
    echo 'set cmd [lrange $argv 1 end]' >> ./exp
    echo 'set password [lindex $argv 0]' >> ./exp
    echo 'eval spawn $cmd' >> ./exp
    echo 'expect "assword:"' >> ./exp
    echo 'send "$password\r";' >> ./exp
    echo -n "interact" >> ./exp
    chmod +x ./exp
}

f () {
    export DATE=$(date | awk '{print $2$3$6}')&& mkdir -p /tmp/logs/${DATE}
    ASROOT="sudo -H -u root bash -c ${1}" 
    ${ASROOT} "cd ${LOGDIR}; tar cpvzf /tmp/logs/${DATE}/logs_`hostname`_${DATE}.tgz *; chmod -R 777 /tmp/logs/${DATE}/logs_`hostname`_${DATE}.tgz &> /dev/null; ls /tmp/logs/${DATE}/logs_`hostname`_${DATE}.tgz"
}

getPw () {
    echo
 	echo "What's the username for ${RESOURCEGROUP}?"
    echo
    read UN
    echo
    echo "What's the password for ${RESOURCEGROUP}?"
    echo
    read -s PW
}

menu () {
    echo
    PS3='Where would you like to get logs from? '
    echo
    options=("AzureResourceGroup1" "AzureResourceGroup2" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "AzureResourceGroup1")
                #Azure Resource Group Name
                RESOURCEGROUP="AzureResourceGroup1"
                echo "Setting to ${RESOURCEGROUP}"
                break
                ;;
            "AzureResourceGroup2")
                #Azure Resource Group Name
                RESOURCEGROUP="AzureResourceGroup2"
                echo "Setting to ${RESOURCEGROUP}"
            	break
                ;;
            "Quit")
                exit
                ;;
            *) echo invalid option;;
        esac
    done
}


go () {
    azure account set ${SUBSCRIPTIONID}
    nics=($(azure resource list "${RESOURCEGROUP}" -r Microsoft.Network/networkInterfaces --json | jq -r '.[] | .name'))
    for vm in "${nics[@]}"
    do
        IP=$(azure network nic show -g "${RESOURCEGROUP}" -n "${vm}" --json | jq -r '.ipConfigurations[0].privateIPAddress')
        TMP=.tmp
        export GROSS=$(./exp ${PW} ssh -o StrictHostKeyChecking=no -t ${UN}@${IP} "$(typeset -f); f")
        ${GROSS} &> /dev/null
        export SRVRFLDR=$(echo ${GROSS} | sed 's#\(.*\)/.*#\1#' | awk '{print $(NF--)}')
        mkdir -p logs &> /dev/null
        echo "${SRVRFLDR} `pwd`/logs" > ${TMP}
        cat $TMP
        ./exp ${PW} scp -o StrictHostKeyChecking=no -pr ${UN}@${IP}:$(cat $TMP)
    done

    echo;echo "Completed! Your logs can be found on your local machine in `pwd`/logs under the folder with today's date.";echo
}

clear
banner
preflightCheck
menu
getPw
clear
go
