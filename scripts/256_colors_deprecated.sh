#!/bin/bash

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.

for fgbg in 38 48 ; do #Foreground/Background
	for color in {0..256} ; do #Colors
		#Display the color
		echo -en "\033[${fgbg};5;${color}m ${color}\t\033[0m"
		#Display 10 colors per lines
		if [[ $((($color + 1) % 10)) == 0 ]] ; then
			echo #New line
		fi
	done
	echo #New line
done

for color in {0..256} ; do #Colors
  #Display the color
  echo -e "\033[48;5;${color}m [${color}] The quick brown fox jumps over the lazy dog THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG'S BACK 1234567890 \033[0m"
done
echo #New line

exit 0
