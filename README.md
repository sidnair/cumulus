# Cumulus
Cumulus is a simple shell script I wrote to let me quickly take screenshots,
upload them to a url, and share them.

I missed this after using CloudApp on OS X. There wasn't a good alternative on
Linux, and the free tier on OS X was crippled.

# Behavior
Run the script, click and drag to select an area of your screen. A screenshot
will be saved in ~/.cumulus (if you want to retrieve it later), and a
notification will appear once the image is uploaded and copied to your
clipboard.

# Installation
Run the cumulus.sh script directly, or bind it to a hotkey (e.g. as a KDE custom
shortcut).

`make install` puts `cumulus` in your path.

Create a `~/.cumulusrc` file which contains an imgur client id.

# Requirements

For Linux:
- scrot
- notify-send
- xsel


For OS X:
- terminal-notifier
