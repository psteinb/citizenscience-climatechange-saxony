
stations.csv : ##will produce csv with columns: "station_id", "date_start", "date_end","geo_lon", "geo_lat", "height", "name", "state"
	@dwdweather stations -t csv | egrep -i ',Sachsen'| grep -v 'Anhalt'|grep -v Baden > stations.csv
