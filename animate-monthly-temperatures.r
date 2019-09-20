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
  summarize( refmedian = median(MO_TT), refmax = median(MO_TX), refmin = median(MO_TN))
    

                                        #TODO: add german map
#https://nceas.github.io/oss-lessons/spatial-data-gis-law/3-mon-intro-gis-in-r.html
temps_station = temps %>%
    mutate(yr= as.integer(year(ymd(MESS_DATUM_BEGINN))), mo= month(ymd(MESS_DATUM_BEGINN))) %>%
    filter(yr > 1945, ! is.na(MO_TT) , STATIONS_ID %in% common) %>% 
    left_join(ref_median_year, by=c('STATIONS_ID' = 'STATIONS_ID', 'mo' = 'mo')) %>%
  mutate( anom = MO_TT - refmedian,
         max_anom = MO_TX - refmax ,
         min_anom = MO_TN - refmin ) %>%
    group_by(STATIONS_ID,yr) %>%
    summarize( anom_total     = round(sum(anom),0),
              max_anom_total = round(sum(max_anom),0),
              min_anom_total = round(sum(min_anom),0),
              anom_median_rounded    = round(median(anom),0),
              anom_median    = median(anom),
              max_anom_median= round(median(max_anom),0),
              min_anom_median= round(median(min_anom),0)
              ) %>%
    left_join(stations, by=c('STATIONS_ID' = 'STATIONS_ID'))



nyears = length(unique(temps_station$yr))
sac <- sf::st_read("shapes/vg2500_bld.shp", quiet = TRUE)  %>% filter(GEN %in% "Sachsen")

# https://github.com/thomasp85/gganimate
anplot = ggplot(sac) +
  geom_sf() +
  geom_point(data=temps_station,aes(x=geo_lon,
                                    y=geo_lat,
                                    color=anom_median_rounded,
                                    size=abs(anom_median)*50)) +
    theme_minimal() +
    scale_color_gradient2(midpoint=0, low="blue", mid="white",
                           high="red", space ="Lab" ) +
    xlab("Monat") +
    ylab("Durchschnitstemperatur") +
  labs(title = 'Jahr: {frame_time}, Anomalie der Monatsmitteltemperatur im Jahr (Referenz 1950-1981)',
       caption = 'Datenquelle: DWD, Code: https://github.com/psteinb/citizenscience-climatechange-saxony',
       x = 'Länge',
       y = 'Breite') +
  guides(size = "none", color= guide_legend(title = "Anomaliewert")) +
  transition_time(yr) +
  ease_aes('cubic-in-out')

anim = animate(anplot,
               nframes=3*nyears,
               duration=20,
               renderer = gifski_renderer(),
               width=700,
               height=500,
               end_pause=20)



anim_save("monthly-temperatures.gif",anim)

anplot = ggplot(sac) +
  geom_sf() +
  geom_point(data=temps_station,aes(x=geo_lon,
                                    y=geo_lat,
                                    color=min_anom_median,
                                    size=abs(min_anom_median)*30)) +
    theme_minimal() +
    scale_color_gradient2(midpoint=0, low="blue", mid="white",
                           high="red", space ="Lab" ) +
    xlab("Monat") +
    ylab("Durchschnitstemperatur") +
    labs(title = 'Jahr: {frame_time}, Anomalie der Monatsmindesttemperatur im Jahr (Referenz 1950-1981)',
         caption = 'Datenquelle: DWD, Code: https://github.com/psteinb/citizenscience-climatechange-saxony',
         x = 'Länge', y = 'Breite') +
  guides(size = "none", color= guide_legend(title = "Anomaliewert")) +
    transition_time(yr) +
  ease_aes('cubic-in-out')

anim = animate(anplot,
               nframes=nyears,
               duration=20,
               renderer = gifski_renderer(),
               width=700,
               height=500,
               end_pause=20)
#magick::image_write(anim, path="monthly-temperatures.gif")
anim_save("monthly-min-temperatures.gif",anim)
