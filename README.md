# Visualizing the climate change in Saxony (Germany)

## Goal

Prepare an annual temperature variation as shown in 
- [spiral](https://www.citylab.com/environment/2017/08/watch-the-worlds-temperatures-spiral-out-of-control/535779/) [code](https://gist.github.com/anttilipp/6b572512ef53cfc6bf949afdc8eb6720)
- [blobs](https://www.flickr.com/photos/150411108@N06/30562013098)
The author of all of this appears to be [Antti Lipponen](https://anttilip.net/)

Ultimately, I'd love to create a hexmap of Saxony like [so](https://gist.github.com/hrbrmstr/51f961198f65509ad863#file-us_states_hexgrid-geojson) and then I'd love to fill the hexagons with temperature deviations from the 1961-1990 median max/min/median temperature and `gganimate` that.

## Data aggregation

- data obtained from [DWD CDC](ftp://ftp-cdc.dwd.de/climate_environment/CDC/observations_germany/climate/monthly/kl/historical) server

    + contains 2 folders __historical__ (01.01.1781 - 31.12.2018) or __recent__
	
- R package [rdwd](https://cran.r-project.org/web/packages/rdwd/vignettes/rdwd.html)
	+ it's hard to find stations inside a state, used DWD's [KL_Monatswerte_Beschreibung_Stationen.txt](ftp://ftp-cdc.dwd.de/climate_environment/CDC/observations_germany/climate/monthly/kl/historical/KL_Monatswerte_Beschreibung_Stationen.txt) directly for that and `grep`ed for ` Sachsen `
    
## How to use?

I have a decent list of dependencies and the code was only used on Fedora 30 (Linux) so far. I use R for vizualisation. Install the dependencies like so:

``` R
install.packages(c("dplyr","gganimate","ggmap","ggplot2","lubridate","rdwd","readr","sf"))
```
To create the animated gif, do:

``` shell
$ make prepare #downloads the list of weather stations
$ make animate #performs the 
```

## Want to help?

Please, open an issue or send a PR.
