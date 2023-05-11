#!/usr/bin/env bash

# Mac GeoComply Remover

#run this as sudo
if [ "$EUID" -ne 0 ]; then 
  echo;echo "Please run as root"
  echo;echo "Example:"
  echo "  sudo $0";echo
  exit
fi

onecount=$(ps -aef | grep PlayerLocationCheck |wc -l)
twocount=$(ps -aef | grep GeoComply |wc -l)
if [ $onecount -gt 1 ]; then
  one=$(ps -aef | grep PlayerLocationCheck | head -1 | awk '{print $2}')
fi
if [ $twocount -gt 1 ]; then
  two=$(ps -aef | grep GeoComply | head -1 | awk '{print $2}')
fi

if [ $onecount -gt 1 ] || [ $twocount -gt 1 ]; then
  mkdir -p /tmp/GeoComply
  kill ${one} ${two}&&\
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
