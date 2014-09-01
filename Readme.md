# DWD Weatherwarnings to Hangouts

checks the WFS of the DWD (Deutsche Wetterdienst) for weatherwarnings in a specified area.

## how to install
- install ruby (the newer the better, 2.1.2 at least)
- either use bundler or install `nokogiri` and `blather` by hand
- modify `config.yml.example` and rename to `config.yml`. Except for `bbox`, all options are required
- set up a cron-job and make sure ruby has write access to the folder where the script lives

## How do i configure the `bbox` and `areadesc`
- `bbox` takes a comma separated list of coordinates of the format `lat,lon,lat,lon` where the first two are from the south-west corner. The last two are from the north east corner of the bounding box. Coordinates are in WGS84, EPSG 3857. Since the WFS only covers Germany, only coordinates within Germany are valid
- `areadesc` is a bit tricky. You should browse to http://wettergefahren.de/ and look at the right hand map. If your desired location is highlighted, open `http://maps.dwd.de/geoserver/ows?service=wfs&version=2.0.0&request=GetFeature&typename=dwd:BASISWARNUNGEN` in your browser and search for your location. Alternatively, you can click yourself through the map until you reach the page which says `Es ist 1 Warnung für <YOUR-AREADESC> vorhanden:`. `<YOUR-AREADESC>` is your areadesc.

## cron example
Assumes rbenv installation (runs the script each 10 minutes)
`*/10 * * * * PATH=$PATH:/usr/local/bin && bash -lc "cd /path/to/folder/weatherwarnings/;/path/to/folder/weatherwarnings.rb"`
