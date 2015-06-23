#!/bin/bash

####################
# Global vars
####################
skip_upload=false
skip_screenshot=false

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
    terminal-notifier -message "$2" -title "$1" -open "$3" -contentImage "$4" -sound Glass
  else
    notify-send $1 $2 -t 3000 --icon=$4
    # notify-send "Cumulus Error" "$1" -t 5000 --icon=dialog-error
    # notify-send "$IMG" "$URL copied to clipboard" -t 3000 --icon=$IMG
  fi
}

# Display error message an exit
error() {
  displayNotification "Cumulus Error" "$1"
  exit 1
}

# Take an interactive screenshot and put it in ~/.cumulus
takeScreenshot() {
  if isMac; then
    screencapture -i ~/.cumulus/screen-$(date +"%m-%d-%Y-%H:%M:%S").png
  else
    (cd ~/.cumulus && scrot -s)
  fi
}

# Pipe text to this function to copy it to the clipboard
clipboard() {
  if isMac; then
    pbcopy
  else
    xsel -i -b
  fi
}

# Upload the specified image path to imgur and print out the path of the image.
uploadImage() {
  ID=$(cat ~/.cumulusrc | tr -d '\n')

  if ! $skip_upload; then
    JSON=`curl -s -XPOST -H "Authorization: Client-ID $ID" -F "image=@$1" https://api.imgur.com/3/upload`
    echo $JSON > ~/.cumulus/.imgur-response # Store for debugging
  fi

  cat ~/.cumulus/.imgur-response | grep -o -P '"http.*?\"' | tr -d '\\"'
}

lastScreenshot() {
  ls -t ~/.cumulus/*.png | head -n 1
}

####################
# Main functions
####################
openLastScreenshot() {
  if isMac; then
    open `lastScreenshot`
  else
    xdg-open `lastScreenshot`
  fi
}

getLastUrl() {
  last_url=`cat ~/.cumulus/.last-url`
  echo $last_url | tee /dev/tty | clipboard
}

doUploadAndCopy() {
  if ! $skip_screenshot; then
    takeScreenshot || error 'Failed to take screenshot'
  fi

  # Grab the most recent screenshot in ~/.cumulus
  img=`lastScreenshot`
  url=`uploadImage $img`
  echo $url | clipboard
  echo $url > ~/.cumulus/.last-url
  displayNotification "$img" "$url copied to clipboard" $url $img
}

####################
# Main execution
####################

[ -e "$HOME/.cumulusrc" ] || error "Missing ~/.cumulusrc. Please create one with your imgur client id."
mkdir -p ~/.cumulus || error "Can't initialize '~/.cumulus directory'"

while [ $# != 0 ]; do
  case "$1" in
    --open-last)
      openLastScreenshot
      exit 0
      ;;
    --get-last-url)
      getLastUrl
      exit 0
      ;;
    --skip-screenshot)
      # Useful for debugging and for retrying the last screenshot
      skip_screenshot=true
      shift 1
      ;;
    --skip-upload)
      # Useful for debugging
      skip_upload=true
      shift 1
      ;;
  esac
done

doUploadAndCopy

exit 0
