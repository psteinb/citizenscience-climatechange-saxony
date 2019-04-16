# script can be executed with
                                        # Rscript temperature-anomalies.r
library(rdwd)

library(readr)
library(ggplot2)
library(dplyr)

stations = read_csv("stations-saxony.csv",
                    col_names=c('station_id','date_start','date_end','geo_lon','geo_lat','height','name','state'))

download_station = function(sid){

    sid_mask = stations$station_id %in% sid
    
    station_info = stations[sid_mask,]

    station_link = selectDWD(id=sid, res='monthly', var='kl', per='historical')
    
    station_data = tryCatch({dataDWD(station_link, progbar=T,read=T)},
                            warning = function(w){ cat(paste('something fishy with',sid,stations$name[sid_mask])); },
                            error = function(e){ print(paste('unable to download',sid,stations$name[sid_mask]));return(NA) },
                            finally = { cat(sid) })

    if(is.null(station_data) || is.na(station_data) == T){
        cat('failed')
        return(station_data)
    }

    
    rdf = station_data %>%
        select(STATIONS_ID,MESS_DATUM_BEGINN,MESS_DATUM_ENDE,QN_4,MO_TT,MO_TX,MO_TN) %>%
        left_join(station_info, by = c("STATIONS_ID"="station_id"))
    
    cat(" obtained","\t",stations$geo_lon[sid_mask],stations$geo_lat[sid_mask],stations$name[sid_mask],'\n')
    
    return(rdf)
}


dflist = sapply(stations$station_id,download_station)
df = bind_rows(dflist)

write_csv(df,'saxony-monthly-temperature.csv')
