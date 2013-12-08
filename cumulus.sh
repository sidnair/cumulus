#!/bin/bash

function uploadImage {
  ID=$(cat ~/.cumulusrc | tr -d '\n')
  JSON=`curl -s -XPOST -H "Authorization: Client-ID $ID" -F "image=@$1" https://api.imgur.com/3/upload`
  echo $JSON | grep -o -P '"http.*?\"' | tr -d '\\"'
}

mkdir -p ~/.cumulus
cd ~/.cumulus

scrot -s
IMG=$(ls -t *.png | head -n 1)
ABSOLUTE_IMG_PATH=`realpath $IMG`
URL=`uploadImage $IMG`
echo $URL | xclip
notify-send "$IMG" "$URL copied to clipboard" -t 3000 --icon=$ABSOLUTE_IMG_PATH

cd - > /dev/null
exit 0
