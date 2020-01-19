#!/bin/sh
# ____                              ____            _                  
#/ ___|  ___ _ __ ___  ___ _ __    / ___|__ _ _ __ | |_ _   _ _ __ ___ 
#\___ \ / __| '__/ _ \/ _ \ '_ \  | |   / _` | '_ \| __| | | | '__/ _ \
# ___) | (__| | |  __/  __/ | | | | |__| (_| | |_) | |_| |_| | | |  __/
#|____/ \___|_|  \___|\___|_| |_|  \____\__,_| .__/ \__|\__,_|_|  \___|
#                                            |_|                       
#
#Captures a screenshot of the screen and saves it to ~/Pictures/Screenshots.
#The destination directory is created if it doesn't exist.
#
#Dependencies -> scrot.

filename="Screenshot_$(date +%Y%m%d_%H%M%S).png"
Dest=$HOME/Pictures/Screenshots
proc=/bin/scrot
#[ -e ~/Pictures ] || mkdir ~/Pictures
[ -e $HOME/Pictures/Screenshots ] || mkdir -p $HOME/Pictures/Screenshots
[ $1 = "full" ] && options='-q 100' 
[ $1 = "selective" ] && options='-s -q 100'
$proc $options $filename && mv -f ./${filename} $Dest
