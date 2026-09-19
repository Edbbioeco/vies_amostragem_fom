# Pacotes ----

library(sf)

library(tidyverse)

library(geobr)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade_fom.shp")

## Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

# Unidades de conservação ----

## Importar ----

uni_con <- geobr::read_conservation_units(date = 202503)

## Visualizar ----

uni_con

ggplot() +
  geom_sf(data = uni_con)

