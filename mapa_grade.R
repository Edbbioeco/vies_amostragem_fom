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

## Continentes ----

### Importar ----

continentes <- rnaturalearth::ne_countries()

## FOM ----

### Importar ----

fom <- sf::st_read("fom.shp")

### Visualizar ----

fom

ggplot() +
  geom_sf(data = br, color = "black") +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen")

## Grade ----

### Importar ----

grade <- sf::st_read("grade_fom.shp")

### Visualizar ----

grade

ggplot() +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = grade, color = "black", fill = "transparent")

