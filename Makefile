##maybe replace by wgetting ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/monthly/kl/historical/KL_Monatswerte_Beschreibung_Stationen.txt

stations.csv : ##will produce csv with columns: "station_id", "date_start", "date_end","geo_lon", "geo_lat", "height", "name", "state"
	@dwdweather stations -t csv | egrep -i ',Sachsen'| grep -v 'Anhalt'|grep -v Baden > stations.csv

station_ids : stations.csv
	@cut -f1 -d, $< > $@
