#!/bin/bash

####################
# Primitives
####################

isMac() {
  uname | grep -q "Darwin"
}

# Display notification. Arguments:
# 1) title
# 2) message
# 3) url to open on click (optional, ignored on Linux)
# 4) icon url (optional)
displayNotification() {
  if isMac; then
    terminal-notifier -message $2 -title $1 -open $3 -contentImage $4 -sound Glass
  else
    notify-send $1 $2 -t 3000 --icon=$4
    # notify-send "Cumulus Error" "$1" -t 5000 --icon=dialog-error
    # notify-send "$IMG" "$URL copied to clipboard" -t 3000 --icon=$IMG
  fi
}

takeScreenshot() {
  if isMac; then
    screencapture -i ~/.cumulus/screen-$(date +"%m-%d-%Y-%H:%M:%S").png
  else
    (cd ~/.cumulus && scrot -s)
  fi
}

clipboard() {
  if isMac; then
    pbcopy
  else
    xsel -i -b
  fi
}

uploadImage() {
  ID=$(cat ~/.cumulusrc | tr -d '\n')
  JSON=`curl -s -XPOST -H "Authorization: Client-ID $ID" -F "image=@$1" https://api.imgur.com/3/upload`
  echo $JSON > ~/.cumulus/.imgur-response # Store for debugging
  cat ~/.cumulus/.imgur-response | grep -o -P '"http.*?\"' | tr -d '\\"'
}

error() {
  displayNotification "Cumulus Error" "$1"
  exit 1
}

####################
# Main execution
####################

[ -e "$HOME/.cumulusrc" ] || error "Missing ~/.cumulusrc. Please create one with your imgur client id."

mkdir -p ~/.cumulus || error "Can't initialize '~/.cumulus directory'"
takeScreenshot || error 'Failed to take screenshot'

img=$(ls -t ~/.cumulus/*.png | head -n 1)
url=`uploadImage $img`
echo $url | clipboard
displayNotification "$img" "$url copied to clipboard" $url $img

exit 0
