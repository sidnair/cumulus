# Cumulus

Cumulus is a simple shell script I wrote to let me quickly take screenshots,
upload them to a url, and share them.

I missed this after using CloudApp on OS X. I couldn't find a very good Linux
utility for this, so I wrote a quick script for myself.

# Behavior
Run the script, click and drag to select an area of your screen. A screenshot
will be saved in ~/.cumulus (if you want to retrieve it later), and a
notification will appear once the image is uploaded and copied to your
clipboard.

If you're running into issues, run the script from the command line and see if
there's any suspicious output.

# Installation
Run the cumulus.sh script directly, or bind it to a hotkey (e.g. as a KDE custom
shortcut).

`make install` puts `cumulus` in your path.

# Requirements
This isn't really designed to be portable, so YMMV.

- ~/.cumulusrc file with an imgur client id
- scrot
- notify-send
- xsel
