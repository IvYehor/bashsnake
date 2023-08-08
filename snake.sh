#!/usr/bin/bash

function cleanup() {
    tput cnorm
    stty echo
}

trap cleanup EXIT

tput civis
stty -echo
clear

Xcoords=(0 0 0)
Ycoords=(0 1 2)

appleX=5
appleY=5

dir=1
# 0 - Up, 1 - Right, 2 - Down, 3 - Left

inp=" "

currtime=$( date -u +%s%N )
newcurrtime=0

while [[ 1 ]]; do

	read -rsn1 -t 0.01 inp 


	if [[ $inp = "w" ]]; then
		dir=0
	elif [[ $inp = "a" ]]; then
		dir=3
	elif [[ $inp = "s" ]]; then
		dir=2
	elif [[ $inp = "d" ]]; then
		dir=1
	fi

	newcurrtime=$( date -u +%s%N )
	if [[ $(( $newcurrtime - $currtime )) -gt 250000000 ]]; then
		currtime=$newcurrtime
		
		Xprevcoord=${Xcoords[-1]}
		Yprevcoord=${Ycoords[-1]}

		i=$(( ${#Xcoords[@]} - 1 ))
		for (( ; i > 0; --i)); do
			Xcoords[$i]=${Xcoords[ $i - 1 ]}
			Ycoords[$i]=${Ycoords[ $i - 1 ]}
		done

		case $dir in
			0)
			Ycoords[0]=$(( ${Ycoords[0]} - 1 ))
			;;
			1)
			Xcoords[0]=$(( ${Xcoords[0]} + 1 ))
			;;
			2)
			Ycoords[0]=$(( ${Ycoords[0]} + 1 ))
			;;
			3)
			Xcoords[0]=$(( ${Xcoords[0]} - 1 ))
			;;
		esac
		if [[ ${Xcoords[0]} -lt 0 ]]; then
			Xcoords[0]=9
		fi
		if [[ ${Ycoords[0]} -lt 0 ]]; then
			Ycoords[0]=9
		fi
		if [[ ${Xcoords[0]} -gt 9 ]]; then
			Xcoords[0]=0
		fi
		if [[ ${Ycoords[0]} -gt 9 ]]; then
			Ycoords[0]=0
		fi

		if [ ${Xcoords[0]} -eq $appleX ] && [ ${Ycoords[0]} -eq $appleY ]; then
			Xcoords+=($Xprevcoord)
			Ycoords+=($Yprevcoord)
			appleX=$(( currtime % 10 ))
			appleY=$(( (currtime / 10) % 10 ))
		fi
	fi


	# Draw field

	echo -ne "\033[12A"
	echo "############"
	for y in {0..9}; do
		echo -n "#"
		for x in {0..9}; do
			if [ $appleX -eq $x ] && [ $appleY -eq $y ]; then
				echo -n "A"
				continue
			fi
			i=0
			for (( ; i < ${#Xcoords[@]}; ++i)) do
				if [ ${Ycoords[$i]} -eq $y ] && [ ${Xcoords[$i]} -eq $x ]; then
					echo -n "S"
					break
				fi
			done
			if [[ !($i -lt ${#Xcoords[@]}) ]]; then
				echo -n " "
			fi
		done
		echo "#"
	done
	echo "############"
done

