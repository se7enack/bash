#!/usr/bin/env bash

#run this as sudo

kill $(ps -aef | grep PlayerLo | head -1 | awk '{print $2}')
kill $(ps -aef | grep GeoComply | head -1 | awk '{print $2}')
mkdir -p /tmp/GeoComply
mv /Library/Application\ Support/GeoComply /tmp/GeoComply/.
mv /Applications/PlayerLocationCheck.app /tmp/GeoComply/.
rm -rf /tmp/GeoComply
