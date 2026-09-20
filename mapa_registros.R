# Pacotes ----

library(geobr)

library(tidyverse)

library(sf)

library(ggview)

# Dados ----

## Shapefile dos estados do Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

### Visualizar ----

br

ggplot() +
  geom_sf(data = br)

## Florestas Ombrófilas Mistas ----

### Importar ----

fom <- sf::st_read("fom.shp")
