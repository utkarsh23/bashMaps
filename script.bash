curlpath="/usr/bin/curl"
imglink="https://maps.googleapis.com/maps/api/staticmap?center=NITK+Surathkal&zoom=14&size=150x90&key=AIzaSyCbpwh-0wO5ERqLcRv6gCts9ZDIW2OXrXE"
imgname="map.png"
flags="-s -o"
store=$($curlpath $imglink $flags $imgname)
catpix map.png
rm "map.png"