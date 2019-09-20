library(rdwd)
library(readr)
library(ggplot2)
library(dplyr)

download_station = function(sid, stations){

  cat('looking into ',sid,'\n')

  if( !is.integer(stations$station_id) ){
    stations$station_id = as.integer(stations$station_id)
  }

  sid_mask = as.integer(stations$station_id) %in% as.integer(sid)

  #extract row for this station
  station_info = stations[sid_mask,]


  station_link = selectDWD(id=sid, res='monthly', var='kl', per='historical')

  station_data = tryCatch({dataDWD(station_link, progbar=T,read=T)},
                          warning = function(w){ cat(paste('something fishy with',sid,stations$name[sid_mask])); },
                          error = function(e){ print(paste('unable to download',sid,stations$name[sid_mask],e));return(NA) },
                          finally = { cat('>> ',sid, 'downloaded') })

  if(is.null(station_data) || is.na(station_data) == T){
    cat('!!',sid,'failed\n')
    return(station_data)
  }

  rdf = station_data %>%
    select(STATIONS_ID,MESS_DATUM_BEGINN,MESS_DATUM_ENDE,QN_4,MO_TT,MO_TX,MO_TN) %>%
    mutate(STATIONS_ID = as.integer(STATIONS_ID)) %>%
    as_tibble()
    ## left_join(station_info, by = c("STATIONS_ID"="station_id")) %>%


  cat(" obtained","\t",stations$geo_lon[sid_mask],stations$geo_lat[sid_mask],stations$name[sid_mask],'\n')
  cat(typeof(rdf))
  return(rdf)
}
