#!/bin/bash

csv="$1"
area="${1%%.*}.are"

Xsiirto=0.000
Ysiirto=0.000
[ "$2" != "" ] && export Xsiirto="$2"
[ "$3" != "" ] && export Ysiirto="$3"

print_header() {
	echo "15=${area%%.*}"
}

print_gdm() {
	echo "5=$Pno"
	echo "4=$Pkoodi"
	echo "90=$pinta"
	echo "91=$viiva"
	echo "37=$Xkoord"
	echo "38=$Ykoord"
	echo "39=$Zkoord"
}

tr -d '\r' < "$csv" |
(
	while read -r line
	 do
		export Pno="$( cut -d, -f 1 <<<"$line" )"
		export Xkoord="$( bc -l <<<"$Xsiirto + $( cut -d, -f 2 <<<"$line" )" )"
		export Ykoord="$( bc -l <<<"$Ysiirto + $( cut -d, -f 3 <<<"$line" )" )"
		export Zkoord="$( cut -d, -f 4 <<<"$line" )"
		export Pkoodi="$( cut -d, -f 5 <<<"$line" )"
		export pinta="$( cut -d, -f 6 <<<"$line" )"
		export viiva="$( cut -d, -f 7 <<<"$line" )"
		print_gdm
	done
) > "$area"
