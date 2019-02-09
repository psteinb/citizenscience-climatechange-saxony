# script can be executed with

library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(gganimate)

temps = read_csv("saxony-monthly-temperature.csv")


ref_median_year = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))), mo= month(ymd(MESS_DATUM_BEGINN))) %>%
    filter(yr < 1981) %>%
    group_by(STATIONS_ID) %>%
    summarize( refmedian = median(MO_TT) ) %>%
    select(STATIONS_ID, refmedian)

glimpse(ref_median_year) #TODO: remove NAs, filter stations 

temps_station = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))), mo= month(ymd(MESS_DATUM_BEGINN))) %>%
    left_join(ref_median_year) %>%
    mutate( anom = MO_TT - refmedian ) %>%
    group_by(yr,STATIONS_ID) %>%
    
# https://github.com/thomasp85/gganimate
anplot = ggplot(temps_station,aes(x=mo,y=anom)) +
    geom_point() +
    geom_jitter() +
    theme_minimal() +
    xlab("Monat") +
    ylab("Durchschnitstemperatur") +
    labs(title = 'Jahr: {frame_time}', x = 'longitude', y = 'latitude') +
    transition_time(yr) +
    ease_aes('linear') 

anim = animate(anplot,
                                        #nframes=15,
               #nps=15,
               renderer = gifski_renderer(),
               width=700,height=500)
#magick::image_write(anim, path="monthly-temperatures.gif")
anim_save("monthly-temperatures.gif",anim)
