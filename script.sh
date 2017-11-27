#!/bin/sh

displayMapWithCoordinates() {
	echo
	echo "LOCATION: $(echo "$1" | tr "+" " ")"
	curlpath="/usr/bin/curl"
	# -s -> silent download
	geoflags="-s"
	geoString="https://maps.googleapis.com/maps/api/geocode/json?address="$1"&key="$key
	# Obtain geodata in JSON format and extract coordinates out of it
	geoInfo=$($curlpath $geoString $geoflags | python3 -c "import sys, json; print(json.load(sys.stdin)['results'][0]['geometry']['location'])")
	echo "Coordinates: $geoInfo"
	imglink="https://maps.googleapis.com/maps/api/staticmap?center="$1"&zoom="$2"&size=150x90&maptype="$3"&key="$key
	imgname="map.png"
	# -o -> to specify the output file for our curl response
	imgflags="-s -o"
	store=$($curlpath $imglink $imgflags $imgname) # Obtain the image using curl and store it in map.png
	catpix map.png -c xy -h 1 -r high # Display map image
	rm "map.png"
}

# key.txt containing Google Maps API key
key=$(cat key.txt)

# Input the location to begin with
echo -n "Enter the address or coordinates (lat,lng): "
read location
location=$(echo "$location" | tr " " "+")  # Replace spaces with '+' (for api link)
zoom=14 # Default zoom
maptype="roadmap" # Default maptype
displayMapWithCoordinates $location $zoom $maptype

while true
do
	echo "OPTIONS"
	echo "1. View the present location"
	echo "2. Change location"
	echo "3. Change zoom on the present location"
	echo "4. Change map view (roadmap <=> satellite) on the present location"
	echo "5. Search for nearby places with the current location"
	echo "6. Exit"
	echo -n "Enter your option: "
	read option
	if [ $option -eq  1 ]
		then
		: # Skip to displaying the image after if-else block
	elif [ $option -eq 2 ]
		then
		echo -n "Enter the new address or coordinates (lat,lng): "
		read location
		location=$(echo "$location" | tr " " "+")
		zoom=14
	elif [ $option -eq 3 ]
		then
		echo -n "Do you wish to zoom in or out?[I/O] "
		read zoomInOrOut
		if [ $zoomInOrOut = "I" ]
			then
			zoom=`expr $zoom + 2` # Increase the zoom by 2 units
		elif [ $zoomInOrOut = "O" ]
			then
			zoom=`expr $zoom - 2` # Decrease the zoom by 2 units
		fi
	elif [ $option -eq 4 ]
		then
		if [ $maptype = "roadmap" ]
			then
			maptype="hybrid" # Hybrid maptype is a hybrid of satellite view and roadmap icons and text
		else
			maptype="roadmap"
		fi
	elif [ $option -eq 5 ]
		then
		echo '\nChoose from the following types of searches'
		pr "types.txt" -3 -t # Display the output in 3 columns
		while true
		do
			echo -n "Enter the type of places you're searching for: "
			read type_of_search
			if grep -Fxq $type_of_search types.txt
				then
				break
			else
				echo "Wrong input! Select from the choices above."
			fi
		done
		echo -n "Enter the radius of your search (< 50,000 [in meters]): "
		read radius
		# Execute the python script for getting places data
		python3 "placesInfo.py" $key $type_of_search $radius $location
		continue
	elif [ $option -eq 6 ]
		then
		break
	fi
	displayMapWithCoordinates $location $zoom $maptype
done
