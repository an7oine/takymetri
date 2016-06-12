#!/bin/bash

gdm="$1"
csv="${1%%.*}.csv"

Xsiirto=0.000
Ysiirto=0.000
if [ "$2" = "+68+244" ]
 then Xsiirto=6800000.000
	Ysiirto=24400000.000
fi

print_csv() {
	if [ -n "$Pkoodi" -a -n "$Pno" -a -n "$Xkoord" -a -n "$Ykoord" ]
	 then
		echo "${Pno},${Xkoord},${Ykoord},${Zkoord},${Pkoodi},${pinta},${viiva}"
	fi
}

tr -d '\r' < "$gdm" |
(
	while read -r line
	 do label="${line%%=*}"
		value="${line##*=}"
		case "$label" in
		 15|50) continue ;;
		 5) print_csv; export Pno="$value" ;;
		 4) export Pkoodi="$value" ;;
		 90) export pinta="$value" ;;
		 91) export viiva="$value" ;;
		 37) export Xkoord=$( bc -l <<<"$Xsiirto + $value" ) ;;
		 38) export Ykoord=$( bc -l <<<"$Ysiirto + $value" ) ;;
		 39) export Zkoord="$value" ;;
		esac
	done
	print_csv
) > "$csv"
