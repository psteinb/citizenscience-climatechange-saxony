# script can be executed with

library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(gganimate)

temps = read_csv("saxony-monthly-temperature.csv")

#find common stations from 1951 - 2017
stats51 = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))),
           mo= as.integer(month(ymd(MESS_DATUM_BEGINN)))) %>%
    filter(yr == 1951, mo == 7) 

stats17 = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))),
           mo= as.integer(month(ymd(MESS_DATUM_BEGINN)))) %>%
    filter(yr == 2017, mo == 7) 

#find stations that are common in both years
common = intersect(stats51$STATIONS_ID,stats17$STATIONS_ID)

#crosscheck
cat(paste(common))

stations = temps %>%
    select(STATIONS_ID, geo_lat, geo_lon, height)%>%
    unique()

#compute median of reference years 1951 to 1981
ref_median_year = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))),
           mo= as.integer(month(ymd(MESS_DATUM_BEGINN)))) %>%
    filter(yr > 1950 & yr < 1982, ! is.na(MO_TT), STATIONS_ID %in% common) %>% 
    group_by(STATIONS_ID, mo) %>% 
    summarize( refmedian = median(MO_TT), refmax = median(MO_TX))
    

                                        #TODO: add german map
#https://nceas.github.io/oss-lessons/spatial-data-gis-law/3-mon-intro-gis-in-r.html
temps_station = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))), mo= month(ymd(MESS_DATUM_BEGINN))) %>%
    filter(yr > 1945, ! is.na(MO_TT) , STATIONS_ID %in% common) %>% 
    left_join(ref_median_year, by=c('STATIONS_ID' = 'STATIONS_ID', 'mo' = 'mo')) %>%
    mutate( anom = MO_TT - refmedian, max_anom = MO_TX - refmax ) %>%
    group_by(STATIONS_ID,yr) %>%
    summarize( anom_total     = round(sum(anom),0),
               max_anom_total = round(sum(max_anom),0),
               anom_median    = round(median(anom),0),
               max_anom_median= round(median(max_anom),0)
              ) %>%
    left_join(stations, by=c('STATIONS_ID' = 'STATIONS_ID'))
    

# https://github.com/thomasp85/gganimate
anplot = ggplot(temps_station,aes(x=geo_lon,y=geo_lat,color=anom_median)) +
    geom_point(size=20) +
    geom_jitter() +
    theme_minimal() +
    scale_color_gradient2(midpoint=0, low="blue", mid="white",
                           high="red", space ="Lab" ) +
                                        #scale_color_gradientn(colors=rev(rainbow(5))) +
    
    xlab("Monat") +
    ylab("Durchschnitstemperatur") +
    labs(title = 'Jahr: {frame_time}, mittlere Temperaturanomalie des Monatsmittel im Vergleich zu 1950-1981', x = 'Laenge', y = 'Breite') +
    transition_time(yr) +
    ease_aes('linear') 

anim = animate(anplot,
                                        #nframes=15,
               fps=2,
               renderer = gifski_renderer(),
               width=700,height=500)

anim_save("monthly-temperatures.gif",anim)

anplot = ggplot(temps_station,aes(x=geo_lon,y=geo_lat,color=max_anom_median)) +
    geom_point(size=20) +
    geom_jitter() +
    theme_minimal() +
                                        #scale_color_gradientn(colors=rev(rainbow(5))) +
    scale_color_gradient2(midpoint=0, low="blue", mid="white",
                           high="red", space ="Lab" ) +
    
    xlab("Monat") +
    ylab("Maximaltemperatur") +
    labs(title = 'Jahr: {frame_time}, mittlere Temperaturanomalie des Monatsmax im Vergleich zu 1950-1981', x = 'Laenge', y = 'Breite') +
    
    transition_time(yr) +
    ease_aes('linear') 

anim = animate(anplot,
                                        #nframes=15,
               fps=2,
               renderer = gifski_renderer(),
               width=700,height=500)
#magick::image_write(anim, path="monthly-temperatures.gif")
anim_save("monthly-max-temperatures.gif",anim)
