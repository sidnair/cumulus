#!/bin/bash

function sendMessage {
  terminal-notifier -message $2 -title $1 -open $3 -contentImage $4 -sound Glass
  # notify-send "Cumulus Error" "$1" -t 5000 --icon=dialog-error
  # notify-send "$IMG" "$URL copied to clipboard" -t 3000 --icon=$IMG
}

function takeScreen {
  screencapture -i ~/.cumulus/screen-$(date +"%m-%d-%Y-%H:%M:%S").png
  # (cd ~/.cumulus && scrot -s)
}

function uploadImage {
  ID=$(cat ~/.cumulusrc | tr -d '\n')
  JSON=`curl -s -XPOST -H "Authorization: Client-ID $ID" -F "image=@$1" https://api.imgur.com/3/upload`
  echo $JSON > ~/.cumulus/.imgur-response # Store for debugging
  cat ~/.cumulus/.imgur-response | grep -o -P '"http.*?\"' | tr -d '\\"'
}

function clipboard {
  pbcopy
  # xsel -i -b
}

function error {
  sendMessage "Cumulus Error" "$1" $URL
  exit 1
}

[ -e "$HOME/.cumulusrc" ] || error "Missing ~/.cumulusrc. Please create one with your imgur client id."

mkdir -p ~/.cumulus || error "Can't initialize '~/.cumulus directory'"
takeScreen || error 'Failed to take screenshot'

IMG=$(ls -t ~/.cumulus/*.png | head -n 1)
URL=`uploadImage $IMG`
echo $URL | clipboard
sendMessage "$IMG" "$URL copied to clipboard" $URL $IMG

exit 0
