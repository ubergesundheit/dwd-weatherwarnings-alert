# DWD Weatherwarnings to Hangouts

checks the WFS of the DWD (Deutsche Wetterdienst) for weatherwarnings in a specified area.

## how to install
- install ruby (the newer the better, 2.1.2 at least)
- either use bundler or install `nokogiri` and `blather` by hand
- modify `config.yml.example` and rename to `config.yml`
- set up a cron-job and make sure ruby has write access to the folder where the script lives

## cron example
Assumes rbenv installation (runs the script each 10 minutes)
`*/10 * * * * PATH=$PATH:/usr/local/bin && bash -lc "cd /path/to/folder/weatherwarnings/;/path/to/folder/weatherwarnings.rb"`
