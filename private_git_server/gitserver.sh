#!/bin/bash

# * This was created for and tested on Ubuntu

REPO="acme-company/git-repo-name"

publicKeyHelp() {
  echo
  echo "Before you start:"
  echo "Please scp your local public key (id_rsa.pub) up to /tmp on the server"
  echo
  echo "Example: scp ~/.ssh/id_rsa.pub `w | awk '{ print $1 }' | tail -1`@`hostname -I | sed -e 's/[[:space:]]*$//'`:/tmp/id_rsa.pub"
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

su -c "useradd git -s /bin/bash -m"
apt-get update
apt-get install -y git
mkdir -p /srv/${REPO}.git
chown git /srv/${REPO}.git
chown git /tmp/id_rsa.pub
ASGIT="sudo -H -u git bash -c ${1}"
${ASGIT} "cd"
${ASGIT} "mkdir -p /home/git/.ssh"
${ASGIT} "cat /tmp/id_rsa.pub >> /home/git/.ssh/authorized_keys"
${ASGIT} "cd /srv/${REPO}.git; git init --bare"
echo "$(which git-shell)" >> /etc/shells
chsh git -s $(which git-shell)
