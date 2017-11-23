#!/bin/sh

displayMapWithCoordinates() {
	echo
	echo "LOCATION: $(echo "$1" | tr "+" " ")"
	curlpath="/usr/bin/curl"
	geoflags="-s"
	geoString="https://maps.googleapis.com/maps/api/geocode/json?address="$1"&key="$key
	geoInfo=$($curlpath $geoString $geoflags | python3 -c "import sys, json; print(json.load(sys.stdin)['results'][0]['geometry']['location'])")
	echo "Coordinates: $geoInfo"
	imglink="https://maps.googleapis.com/maps/api/staticmap?center="$1"&zoom="$2"&size=150x90&maptype="$3"&key="$key
	imgname="map.png"
	imgflags="-s -o"
	store=$($curlpath $imglink $imgflags $imgname)
	catpix map.png -c xy -h 1 -r high
	rm "map.png"
}

key=$(cat key.txt)
echo -n "Enter the address or coordinates (lat,lng): "
read location
location=$(echo "$location" | tr " " "+")
zoom=14
maptype="roadmap"
displayMapWithCoordinates $location $zoom $maptype

while true
do
	echo "OPTIONS"
	echo "1. Change location"
	echo "2. Change zoom on the present location"
	echo "3. Change map view (roadmap <=> satellite) on the present location"
	echo "4. Exit"
	echo -n "Enter your option: "
	read option
	if [ $option -eq 1 ]
		then
		echo -n "Enter the new address or coordinates (lat,lng): "
		read location
		location=$(echo "$location" | tr " " "+")
		zoom=14
	elif [ $option -eq 2 ]
		then
		echo -n "Do you wish to zoom in or out?[I/O] "
		read zoomInOrOut
		if [ $zoomInOrOut = "I" ]
			then
			zoom=`expr $zoom + 2`
		elif [ $zoomInOrOut = "O" ]
			then
			zoom=`expr $zoom - 2`
		fi
	elif [ $option -eq 3 ]
		then
		if [ $maptype = "roadmap" ]
			then
			maptype="hybrid"
		else
			maptype="roadmap"
		fi
	elif [ $option -eq 4 ]
		then
		break
	fi
	displayMapWithCoordinates $location $zoom $maptype
done
