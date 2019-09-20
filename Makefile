##maybe replace by wgetting ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/monthly/kl/historical/KL_Monatswerte_Beschreibung_Stationen.txt

# stations.csv : ##will produce csv with columns: "station_id", "date_start", "date_end","geo_lon", "geo_lat", "height", "name", "state"
# 	@dwdweather stations -t csv | egrep -i ',Sachsen'| grep -v 'Anhalt'|grep -v Baden > stations.csv

all: prepare

show_packages:
	grep -h library *r|sort -u|sed -e 's/library(//' -e 's/)//'|tr '\n' ','

station_ids : stations.csv
	@cut -f1 -d, $< > $@

KL_Monatswerte_Beschreibung_Stationen.txt:
	@wget ftp://ftp-cdc.dwd.de/climate_environment/CDC/observations_germany/climate/monthly/kl/historical/KL_Monatswerte_Beschreibung_Stationen.txt

KL_Monatswerte_Beschreibung_Stationen_no_umlaute.txt: KL_Monatswerte_Beschreibung_Stationen.txt
	@sed -e 's/\xfc/ue/g' -e 's/\xdf/ss/g' -e 's/\xe4/ae/g' -e 's/\xf6/oe/g' $< > $@

stations.csv : KL_Monatswerte_Beschreibung_Stationen_no_umlaute.txt
	@egrep --binary-files=text ' Sachsen ' $< |sed -e 's/Sachsen/,Sachsen/g' -e 's/\([0-9]\) /\1,/g'|tr -d ' '|awk -F ',' '{print $$1, $$2, $$3, $$6, $$5, $$4, $$7, $$8}'|tr ' ' ',' > $@

saxony-monthly-temperature.csv : stations.csv
	@Rscript download-saxony-monthly-temperature.r $<

prepare : saxony-monthly-temperature.csv
