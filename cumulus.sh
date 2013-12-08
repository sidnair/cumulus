#!/bin/bash

function uploadImage {
  ID=$(cat ~/.cumulusrc | tr -d '\n')
  JSON=`curl -s -XPOST -H "Authorization: Client-ID $ID" -F "image=@$1" https://api.imgur.com/3/upload`
  echo $JSON > ~/.cumulus/.imgur-response # Store for debugging
  echo $JSON | grep -o -P '"http.*?\"' | tr -d '\\"'
}

function error {
  notify-send "Cumulus Error" "$1" -t 5000 --icon=dialog-error
  exit 1
}

if [ ! -e "$HOME/.cumulusrc" ]
then
  error "Invalid ~/.cumulusrc. Please create one with your imgur client id."
fi


mkdir -p ~/.cumulus
(cd ~/.cumulus && scrot -s) || error 'Failed to take screenshot'

IMG=$(ls -t ~/.cumulus/*.png | head -n 1)
URL=`uploadImage $IMG`
echo $URL | xclip
notify-send "$IMG" "$URL copied to clipboard" -t 3000 --icon=$IMG

exit 0
