# script can be executed with

library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(gganimate)

temps = read_csv("saxony-climate.csv")

glimpse(temps)

temp_median_year = temps %>% mutate(yr= year(ymd(MESS_DATUM_BEGINN)), mo= month(ymd(MESS_DATUM_BEGINN))) %>% filter(mo == 2)%>% group_by(yr,STATIONS_ID)

glimpse(temp_median_year)
# https://github.com/thomasp85/gganimate
plot = ggplot(temp_median_year,aes(latitude,longitude,color=MO_TT)) + geom_point(size=4) + xlab("latitude") + ylab("longitue") + labs(title = 'Year: {frame_time}', x = 'latitude', y = 'longitude') +
  transition_time(yr) +
  ease_aes('linear')

animate(plot, renderer = file_renderer())#creates tons of files

