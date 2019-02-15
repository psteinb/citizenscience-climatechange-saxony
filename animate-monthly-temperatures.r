# script can be executed with

library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(gganimate)

temps = read_csv("saxony-monthly-temperature.csv")


stats51 = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))),
           mo= as.integer(month(ymd(MESS_DATUM_BEGINN)))) %>%
    filter(yr == 1951, mo == 7) 

stats17 = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))),
           mo= as.integer(month(ymd(MESS_DATUM_BEGINN)))) %>%
    filter(yr == 2017, mo == 7) 

common = intersect(stats51$STATIONS_ID,stats17$STATIONS_ID)

ref_median_year = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))),
           mo= as.integer(month(ymd(MESS_DATUM_BEGINN)))) %>%
    filter(yr > 1945 & yr < 1981, ! is.na(MO_TT), STATIONS_ID %in% common) %>% 
    group_by(STATIONS_ID, mo) %>% 
    summarize( refmedian = median(MO_TT), refmax = median(MO_TX) ) 


glimpse(ref_median_year) #TODO: remove NAs, filter stations 

temps_station = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))), mo= month(ymd(MESS_DATUM_BEGINN))) %>%
    filter(yr > 1945, ! is.na(MO_TT) , STATIONS_ID %in% common) %>% 
    left_join(ref_median_year, by=c('STATIONS_ID' = 'STATIONS_ID', 'mo' = 'mo')) %>%
    mutate( anom = MO_TT - refmedian, max_anom = MO_TX - refmax ) %>%
    group_by(yr,STATIONS_ID) 
    

# https://github.com/thomasp85/gganimate
anplot = ggplot(temps_station,aes(x=mo,y=anom,color=anom)) +
    geom_point(size=4) +
    geom_jitter() +
    theme_minimal() +
    scale_color_gradientn(colors=rainbow(5)) + #TODO: how to invert this?
    xlab("Monat") +
    ylab("Durchschnitstemperatur") +
    labs(title = 'Jahr: {frame_time}', x = 'Monat', y = 'Anomalie: T - median(Jahr < 1981)') +
    transition_time(yr) +
    ease_aes('linear') 

anim = animate(anplot,
                                        #nframes=15,
               fps=7,
               renderer = gifski_renderer(),
               width=700,height=500)
#magick::image_write(anim, path="monthly-temperatures.gif")
anim_save("monthly-temperatures.gif",anim)

# https://github.com/thomasp85/gganimate
anplot = ggplot(temps_station,aes(x=mo,y=max_anom,color=max_anom)) +
    geom_point(size=4) +
    geom_jitter() +
    theme_minimal() +
    scale_color_gradientn(colors=rainbow(5)) + #TODO: how to invert this?
    xlab("Monat") +
    ylab("Maximaltemperatur") +
    labs(title = 'Jahr: {frame_time}', x = 'Monat', y = 'Anomalie: T - median(Jahr < 1981)') +
    transition_time(yr) +
    ease_aes('linear') 

anim = animate(anplot,
                                        #nframes=15,
               fps=7,
               renderer = gifski_renderer(),
               width=700,height=500)
#magick::image_write(anim, path="monthly-temperatures.gif")
anim_save("monthly-max-temperatures.gif",anim)
