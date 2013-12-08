#!/bin/bash

function uploadImage {
  ID=$(cat ~/.cumulus | tr -d '\n')
  JSON=`curl -s -XPOST -H "Authorization: Client-ID $ID" -F "image=@$1" https://api.imgur.com/3/upload`
  echo $JSON | grep -o -P '"http.*?\"' | tr -d '\\"'
}

TMPDIR=`mktemp -d`
# http://stackoverflow.com/questions/2472629/temporary-operation-in-a-temporary-directory-in-shell-script
trap "{ cd - ; rm -rf $TMPDIR; exit 255; }" SIGINT
cd $TMPDIR

scrot -s
IMG=`ls *.png`
ABSOLUTE_IMG_PATH=`realpath $IMG`
URL=`uploadImage $IMG`
echo $URL | xclip
notify-send "$IMG" "$URL copied to clipboard" -t 3000 --icon=$ABSOLUTE_IMG_PATH

# Clean up. Note we don't remove the tmp dir so the notifier can use the icon.
cd - > /dev/null
exit 0
