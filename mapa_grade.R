# Pacotes ----

library(geobr)

library(tidyverse)

library(sf)

library(cowplot)

library(ggview)

# Dados ----

## Shapefile dos estados do Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

### Visualizar ----

br

ggplot() +
  geom_sf(data = br, color = "black")

## FOM ----

### Importar ----

fom <- sf::st_read("fom.shp")
