import time, sys, json, urllib.request

def getJsonFromUrl(requestUrl):
	req = urllib.request.Request(requestUrl)
	return json.loads(urllib.request.urlopen(req).read().decode('utf-8'))

def main():
	key = sys.argv[1]
	type_of_search = sys.argv[2]
	radius = sys.argv[3]
	location = sys.argv[4]
	coordsRequestUrl = "https://maps.googleapis.com/maps/api/geocode/json?address=" + location + "&key=" + key
	coordinates_data = getJsonFromUrl(coordsRequestUrl)['results'][0]['geometry']['location']
	latitude = coordinates_data['lat']
	longitude = coordinates_data['lng']
	dataRequestUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + str(latitude) + "," + str(longitude) + "&radius=" + radius + "&type=" + type_of_search + "&key=" + key
	nearby_places_data = getJsonFromUrl(dataRequestUrl)['results']
	print()
	if len(nearby_places_data) == 0:
		print("\tNo search results.")
		print()
		return
	for placeindex in range(min(len(nearby_places_data), 20)):
		print("\tPlace #" + str(placeindex + 1))
		placeKeys = nearby_places_data[placeindex].keys()
		if "name" in placeKeys:
			print("\tName: " + nearby_places_data[placeindex]["name"])
		if "vicinity" in placeKeys:
			print("\tAddress: " + nearby_places_data[placeindex]["vicinity"])
		place_latitude = nearby_places_data[placeindex]["geometry"]["location"]["lat"]
		place_longitude = nearby_places_data[placeindex]["geometry"]["location"]["lng"]
		print("\tLatitude: " + str(place_latitude))
		print("\tLongitude: " + str(place_longitude))
		print()

if __name__ == '__main__':
	main()