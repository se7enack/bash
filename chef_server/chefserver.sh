#!/bin/bash

# Run this as root or a sudo'er - Stephen Burke 

USER=admin
PW=1234Easy
ORG1=devops # simple org name
ORG2="DevOps Test Org" # full org name 
EMAIL=steburke71@hotmail.com
FIRSTNAME=Stephen
LASTNAME=Burke

ufw disable
URL='https://packages.chef.io/stable/ubuntu/16.04/chef-server-core_12.9.1-1_amd64.deb'

apt-get update
apt-get upgrade -y

wget "$URL" -qO file.deb && sudo dpkg -i file.deb; rm file.deb

chef-server-ctl reconfigure
chef-server-ctl user-create $USER $FIRSTNAME $LASTNAME $EMAIL $PW --filename ~/$USER.pem
chef-server-ctl org-create $ORG1 $ORG2 --association_user $USER --filename ~/$USER.pem
chef-server-ctl install chef-manage
chef-server-ctl reconfigure
chef-manage-ctl reconfigure

echo ""
echo ""
echo ""
echo "username is: $USER"
echo "password is: $PW"
echo ""
echo ""
echo ""
