# script can be executed with

library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(gganimate)

temps = read_csv("saxony-monthly-temperature.csv")

glimpse(temps)

temp_median_year = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))), mo= month(ymd(MESS_DATUM_BEGINN))) %>%
    #filter(mo == 2)%>%
    group_by(yr,STATIONS_ID)

glimpse(temp_median_year)

anplot = ggplot(temp_median_year,aes(MO_TT)) +
    geom_histogram() +
    facet_wrap(~ mo) + 
    theme_minimal() +
    xlab("Temperatur")
  
ggsave("histo_monthly.png",anplot)

hplot = ggplot(temp_median_year,aes(height)) +
    geom_histogram() +
    theme_minimal() +
    xlab("Hoehe")
  
ggsave("histo_heights.png",hplot)
