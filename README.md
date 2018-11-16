# Visualizing the climate change in Saxony (Germany)


## Goal

Prepare an annual temperature variation as shown in 
- [spiral](https://www.citylab.com/environment/2017/08/watch-the-worlds-temperatures-spiral-out-of-control/535779/) [code](https://gist.github.com/anttilipp/6b572512ef53cfc6bf949afdc8eb6720)
- [blobs](https://www.flickr.com/photos/150411108@N06/30562013098)
The author of all of this appears to be [Antti Lipponen](https://anttilip.net/)

Ultimately, I'd love to create a hexmap of Saxony like [so](https://gist.github.com/hrbrmstr/51f961198f65509ad863#file-us_states_hexgrid-geojson) and then I'd love to fill the hexagons with temperature deviations from the 1961-1990 median max/min/median temperature and `gganimate` that.

## Data aggregation

- data obtained from [DWD CDC](ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/daily/kl/) server

    + contains 2 folders __historical__ (01.01.1781 - 31.12.2017) or __recent__
	
- python module [dwdweather](https://github.com/marians/dwd-weather) 
  
    + no historical data?
    + command line app to explore station IDs
	+ submitted this [PR](https://github.com/marians/dwd-weather/compare/master...psteinb:py3-fixes?expand=1)
	    - used this to rextract stations in Saxony:
		```
		python3 ./dwdweather.py stations -t csv -r ',Sachsen[^-]'|cut -d, -f1 > ~/development/climatechange-saxony/station_ids
		```
	
- R package [rdwd](https://cran.r-project.org/web/packages/rdwd/vignettes/rdwd.html)
	+ it's hard to find stations inside a state, used python package for this

## Data Viz

### in R

- http://www.milanor.net/blog/maps-in-r-choropleth-maps/
- http://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html
- https://rud.is/b/2015/05/14/geojson-hexagonal-statebins-in-r/

- (admin state boundaries) https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/countries#countries16


