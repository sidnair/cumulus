#!/bin/bash
set -eu

####################
# Global vars
####################
skip_upload=false
skip_screenshot=false
whole_screen=false
[ "$(uname)" == "Darwin" ] && is_mac=true || is_mac=false

####################
# Primitives
####################

# Display notification. Arguments:
# 1) title
# 2) message
# 3) url to open on click (optional, ignored on Linux)
# 4) icon url (optional)
display_notification() {
  if $is_mac; then
    terminal-notifier -message "$2" -title "$1" -open "$3" -contentImage "$4" -sound Glass
  else
    notify-send $1 $2 -t 3000 --icon=$4
    # notify-send "Cumulus Error" "$1" -t 5000 --icon=dialog-error
    # notify-send "$IMG" "$URL copied to clipboard" -t 3000 --icon=$IMG
  fi
}

# Display error message an exit
error() {
  display_notification "Cumulus Error" "$1" "" ""
  exit 1
}

# Take an interactive screenshot and put it in ~/.cumulus
take_screenshot() {
  filename=~/.cumulus/screen-$(date +"%m-%d-%Y-%H:%M:%S").png

  case "$is_mac-$whole_screen" in
    "true-true") screencapture $filename;;
    "true-false") screencapture -i $filename;;
    "false-true") scrot $filename;;
    "false-false") scrot -s $filename;;
  esac
}

# Pipe text to this function to copy it to the clipboard
clipboard() {
  if $is_mac; then
    pbcopy
  else
    xsel -i -b
  fi
}

# Upload the specified image path to imgur and print out the path of the image.
upload_image() {
  ID=$(cat ~/.cumulusrc | tr -d '\n')

  if ! $skip_upload; then
    JSON=`curl -s -XPOST -H "Authorization: Client-ID $ID" -F "image=@$1" https://api.imgur.com/3/upload`
    echo $JSON > ~/.cumulus/.imgur-response # Store for debugging
  fi
}

get_last_url() {
  cat ~/.cumulus/.imgur-response | grep -o -P '"http.*?\"' | tr -d '\\"'
}

last_screenshot() {
  ls -t ~/.cumulus/*.png | head -n 1
}

####################
# Main functions
####################
open_last_screenshot() {
  if $is_mac; then
    open `last_screenshot`
  else
    xdg-open `last_screenshot`
  fi
}

cumulus_main() {
  if ! $skip_screenshot; then
    take_screenshot || error 'Failed to take screenshot'
  fi

  # Grab the most recent screenshot in ~/.cumulus
  local img=`last_screenshot`
  upload_image $img
  local url=`get_last_url`
  echo $url | clipboard
  display_notification "$img" "$url copied to clipboard" $url $img
}

print_usage() {
  echo "usage: $0 [ --open-last | --get-last-url | [ [--skip-screenshot] [--skip-upload] ]"
  echo ""
  echo "  -h, --help             Output this usage message and exit."
  echo "  --get-last-url         Echo the last imgur url and copy it to the clipboard."
  echo "  --open-last            Open the last image."
  echo "  --whole-screen          Take a screenshot of the whole screen. Don't prompt for selection."
  echo "  --skip-screenshot      Don't take a screenshot, just use the last image. Useful for debugging."
  echo "  --skip-upload          Don't upload an image, but reuse the last url. Useful for debugging."
}

####################
# Main execution
####################

[ -e "$HOME/.cumulusrc" ] || error "Missing ~/.cumulusrc. Please create one with your imgur client id."
mkdir -p ~/.cumulus || error "Can't initialize '~/.cumulus directory'"

while [ $# != 0 ]; do
  case "$1" in
    -h | --help)
      print_usage
      exit 0
      ;;
    --open-last)
      open_last_screenshot
      exit 0
      ;;
    --get-last-url)
      get_last_url
      exit 0
      ;;
    --skip-screenshot)
      skip_screenshot=true
      shift 1
      ;;
    --skip-upload)
      skip_upload=true
      shift 1
      ;;
    --whole-screen)
      whole_screen=true
      shift 1
      ;;
    *)
      echo "Unknown option $1."
      echo ""
      print_usage
      exit 1;
  esac
done

cumulus_main

exit 0
