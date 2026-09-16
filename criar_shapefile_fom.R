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

## Filtrar ----

fom <- veg |> dplyr::filter(nm_pretet == "Floresta Ombrófila Mista")

## Visualizar -----

fom

fom |> dplyr::glimpse()

ggplot() +
  geom_sf(data = br, color = "black") +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen", alpha = 0.3)

## Exportar ----

fom |> sf::st_write("fom.shp")
