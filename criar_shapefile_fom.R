# Pacotes ----

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

## Formações vegetais do Brasil ----

### Importar ----

veg <- sf::st_read("vege_area.shp")

### Visualizar ----

veg

veg |> dplyr::glimpse()

ggplot() +
  geom_sf(data = br, color = "black") +
  geom_sf(data = veg, color = "darkgreen")

# Filtrando apenas para a FOM ----

## Filtrando ----

fom <- veg |> dplyr::filter(nm_pretet == "Floresta Ombrófila Mista")
