#!/usr/bin/env bash

# Mac GeoComply Remover

#run this as sudo
if [ "$EUID" -ne 0 ]; then 
  echo;echo "Please run as root"
  echo;echo "Example:"
  echo "  sudo $0";echo
  exit
fi

plc=$(ps -aef | grep PlayerLocationCheck |wc -l)
gc=$(ps -aef | grep GeoComply |wc -l)
if [ $plc -gt 1 ]; then
  plcPid=$(ps -aef | grep PlayerLocationCheck | head -1 | awk '{print $2}')
fi
if [ $gc -gt 1 ]; then
  gcPid=$(ps -aef | grep GeoComply | head -1 | awk '{print $2}')
fi

if [ $plc -gt 1 ] || [ $gc -gt 1 ]; then
  mkdir -p /tmp/GeoComply
  kill -9 ${plcPid} ${gcPid}&&\
  mv /Library/Application\ Support/GeoComply /tmp/GeoComply/.&&\
  mv /Applications/PlayerLocationCheck.app /tmp/GeoComply/.&&\
  rm -rf /tmp/GeoComply
  if [ $? -eq 0 ]; then
    osascript <<EOT
      tell app "System Events"
        display dialog "$1" buttons {"OK"} default button 1 with icon note with title "Removed"
        return  -- Suppress result
      end tell
EOT
  else
    osascript <<EOT
      tell app "System Events"
        display dialog "$1" buttons {"OK"} default button 1 with icon stop with title "Failed"
        return  -- Suppress result
      end tell
EOT
  fi
else
  osascript <<EOT
    tell app "System Events"
      display dialog "$1" buttons {"OK"} default button 1 with icon caution with title "Not Installed"
      return  -- Suppress result
    end tell
EOT
fi
