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
