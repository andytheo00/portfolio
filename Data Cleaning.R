library(tidyverse)
library(sf)
library(haven)
library(acled.api)
library(lubridate)

setwd("~/Desktop/Harvard/Fall 2022/CS 109/Final Project")

horn_acled <- acled.api(
  email.address = "kmazur@crisisgroup.org",
  access.key = "5Q!imTAT*G4GSIPhbaCa",
  country = c("Somalia", "Kenya", "Ethiopia", "Uganda", "Sudan", "South Sudan", "Djibouti", "Eritrea"),
  start.date = "2000-02-01",
  end.date = "2022-05-31",
  add.variables = NULL,
  all.variables = TRUE,
  dyadic = FALSE,
  interaction = NULL,
  other.query = NULL
)

horn_acled = horn_acled %>% filter(geo_precision != 3)

horn_acled$event_date = as.Date(horn_acled$event_date)

horn_total = horn_acled %>% group_by(month = floor_date(event_date, "month"), longitude, latitude) %>% summarise(total_deaths = n())
horn_total

event_types = horn_acled %>% select(longitude, latitude, event_date, event_type, timestamp, fatalities) %>% 
  pivot_wider(names_from = event_type, values_from = c(timestamp), values_fn = (timestamp = length))

event_types$total_counts = rowSums( event_types[,5:10], na.rm = TRUE)

#Transforming the point data into a spatial object
event_types_spdf = st_as_sf(event_types, 
                                  coords = c("longitude", "latitude"),
                                  crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")


#Upload the horn shp file 

horn_shp = st_read("horn_clean.shp")

horn_shp_acled = st_join(horn_shp, event_types_spdf, left =TRUE)

view(horn_shp_acled)

horn_ndvi = read_csv("horn_ndvi.csv")
horn_floods


#Joining the grid cell and the fatalities dataset above

ph_wider_grid = st_join(philippines_cells_smaller2, philippines_wider_spdf, left=TRUE)