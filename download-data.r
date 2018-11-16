# script can be executed with
                                        # Rscript temperature-anomalies.r
library(rdwd)

library(readr)

stations = read_csv("station_ids", col_names=FALSE)

#TODO: loop through all stations and run selectDWD for each station
selected = selectDWD(id=stations)
