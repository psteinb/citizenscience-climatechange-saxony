# script can be executed with
# Rscript download-saxony-monthly-temperature.r <csv file>
args<-commandArgs(TRUE)

if(length(args) < 1){
  message("Usage: download-saxony-monthly-temperature.r <csv file>")
  stop("no csv file provided")
}


library(rdwd)

library(readr)
library(ggplot2)
library(dplyr)

source("rdwd_tools.r")

available_stations = read_csv(
  args[1],
  col_names=c('station_id','date_start','date_end','geo_lon','geo_lat','height','name','state')) %>%
  mutate(station_id = as.integer(station_id))

dflist = lapply(available_stations$station_id,
                download_station,
                stations=available_stations)

message('merging downloaded datasets')

df = bind_rows(dflist) %>%
  left_join(available_stations, by = c("STATIONS_ID"="station_id"))

ofile = 'saxony-monthly-temperature.csv'
write_csv(df,ofile)
message('data written to ',ofile)
