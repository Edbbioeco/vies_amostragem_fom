# Pacotes ----

library(sf)

library(tidyverse)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade_fom.shp")

## Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

# Áreas urbanas ----

## Importar ----

areas_urb <- geobr::read_urban_area(year = 2022)
