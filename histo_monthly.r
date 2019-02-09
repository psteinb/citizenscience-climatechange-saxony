# script can be executed with

library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(gganimate)

temps = read_csv("saxony-monthly-temperature.csv")


temp_median_year = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))), mo= month(ymd(MESS_DATUM_BEGINN))) %>%
    #filter(mo == 2)%>%
    group_by(yr,STATIONS_ID)

# https://github.com/thomasp85/gganimate
anplot = ggplot(temp_median_year,aes(MO_TT)) +
    geom_histogram() +
    facet_wrap(~ mo) + 
    theme_minimal() +
    xlab("Temperatur") +
    labs(title = 'Year: {frame_time}', x = 'Temperatur', y = 'N') +
    transition_time(yr) +
    ease_aes('linear') 

anim = animate(anplot,
               #nframes=15,
               renderer = gifski_renderer(), width=500,height=350)
#magick::image_write(anim, path="monthly-temperatures.gif")
anim_save("histo_monthly.gif",anim)
