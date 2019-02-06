# script can be executed with

library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(gganimate)

temps = read_csv("saxony-monthly-temperature.csv")


temp_median_year = temps %>% mutate(yr= year(ymd(MESS_DATUM_BEGINN)), mo= month(ymd(MESS_DATUM_BEGINN))) %>% filter(mo == 2)%>% group_by(yr,STATIONS_ID)

# https://github.com/thomasp85/gganimate
anplot = ggplot(temp_median_year,aes(x=geo_lon,y=geo_lat,color=MO_TT)) + geom_point(size=4) + xlab("longitude") + ylab("latitude") + labs(title = 'Year: {frame_time}', x = 'longitude', y = 'latitude') +
  transition_time(yr) +
  ease_aes('linear')

anim = animate(anplot, renderer = magick_renderer())
magick::image_write(anim, path="monthly-temperatures.gif")