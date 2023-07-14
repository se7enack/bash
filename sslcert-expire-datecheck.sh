#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "curl --insecure -vvI https://${1} 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }' | grep expire|awk -F \":\" '{print $2 \"\" $4}' | awk '{print $1,$2,$4}'" >/usr/local/bin/expires

echo;echo "Installed!"
echo "  Usage:  'expires github.com'"
echo "  Result: 'Mar 14 2024'";echo
