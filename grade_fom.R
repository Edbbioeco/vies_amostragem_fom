## Pacotes ----

library(geobr)

library(tidyverse)

library(sf)

# Dados ----

## Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

### Visualizar ----

br

ggplot() +
  geom_sf(data = br, color = "black")

## Florestas Ombrófilas Mistas ----

### Importar ----

fom <- sf::st_read("fom.shp")

### Visualizar ----

fom

ggplot() +
  geom_sf(data = br, color = "black") +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen",
          alpha = 0.3)
