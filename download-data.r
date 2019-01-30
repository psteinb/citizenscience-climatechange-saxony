# script can be executed with
                                        # Rscript temperature-anomalies.r
library(rdwd)

library(readr)
library(ggplot2)
library(dplyr)

stations = read_csv("station_ids", col_names=FALSE)



download_station = function(sid){

		 cat("downloading",sid,"/",nrow(stations),"\n")
		 station_link = selectDWD(id=sid, res='monthly', var='kl', per='historical')
		 station_data = tryCatch({dataDWD(station_link)},
					 warning = function(w){ print(paste("warning emitted on station ",sid,w)) },
					 error = function(e){ print(paste("failed to download station ",sid,e)); return(NA) },
					 finally = { print(paste("download station ",sid,'successfull'))  })
		 return(station_data)
}


data = sapply(stations$X1,download_station)



head(df)