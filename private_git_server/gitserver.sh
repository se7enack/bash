#!/bin/bash

# * This was created for and tested on Ubuntu

REPO="acme-company/git-repo-name"

SERVERIP=$(hostname -I | sed -e 's/[[:space:]]*$//')
PUBSERVERIP=$(curl ifconfig.co)
USERNAME=$(w | awk '{ print $1 }' | tail -1)

publicKeyHelp() {
  echo
  echo "Before you start:"
  echo "Please scp your local public key (id_rsa.pub) up to /tmp on the server"
  echo
  echo "Example:"
  echo "scp ~/.ssh/id_rsa.pub ${USERNAME}@${SERVERIP}:/tmp/id_rsa.pub"
  echo
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

ls /tmp/id_rsa.pub &> /dev/null
if [[ $? -ne 0 ]]; then
   publicKeyHelp
   exit 1
fi

su -c "useradd git -s /bin/bash -m" && \
apt-get update && \
apt-get install -y git && \
mkdir -p /${REPO}.git && \
chown git /${REPO}.git && \
chown git /tmp/id_rsa.pub && \
ASGIT="sudo -H -u git bash -c ${1}" && \
${ASGIT} "cd" && \
${ASGIT} "mkdir -p /home/git/.ssh" && \
${ASGIT} "cat /tmp/id_rsa.pub >> /home/git/.ssh/authorized_keys" && \
${ASGIT} "cd /${REPO}.git; git init --bare" && \
echo "$(which git-shell)" >> /etc/shells && \
chsh git -s $(which git-shell)
if [[ $? -eq 0 ]]; then
  clear
  echo
  echo "Complete!"
  echo 
  echo "From your local machine run:"
  echo "git clone git@${SERVERIP}:/${REPO}.git"
  echo "or"
  echo "git clone git@${PUBSERVERIP}:/${REPO}.git"
  echo
else
  echo "ERROR: Review above output for more information"
fi
