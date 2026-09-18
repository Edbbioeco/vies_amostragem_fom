# Pacotes ----

library(sf)

library(tidyverse)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade.shp")

## Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

# Rios e Lagos ----

## Importar ----

rioslagos <- sf::st_read("GEOFT_BHO_REF_RIO.shp")

## Visualizar ----

rioslagos

ggplot() +
  geom_sf(data = rioslagos)
