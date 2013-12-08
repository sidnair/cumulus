# Cumulus

Cumulus is a simple shell script I wrote to let me quickly take screenshots,
upload them to a url, and share them.

I missed this after using CloudApp on OS X. I couldn't find a very good Linux
utility for this, so I wrote a quick script for myself.

# Installation
Run the cumulus.sh script directly, or bind it to a hotkey (e.g. as a KDE custom
shortcut).

NOTE: after running the script, you'll need to drag to select an area of your
screen. I haven't wanted to screenshot the entire screen yet, so that behavior
isn't supported right now.

# Requirements
This isn't really designed to be portable, so YMMV.

Programs I use:

- ~/.cumulus file with an imgur client id
- scrot
- notify-send
- xclip
