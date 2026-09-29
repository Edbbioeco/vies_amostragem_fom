# Pacotes ----

library(geobr)

library(tidyverse)

library(rnaturalearth)

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

### Visualizar ----

continentes

ggplot() +
  geom_sf(data = continentes, color = "black") +
  geom_sf(data = br, color = "black", fill = "white")

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

# Mpas ----

## Insert map ----

insert_map <- ggplot() +
  geom_sf(data = continentes, color = "black", fill = "gray") +
  geom_sf(data = br, color = "black", fill = "white") +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = br, color = "black", fill = "transparent") +
  coord_sf(xlim = c(-72.98681, -35),
           ylim = c(-32.75108, 4.26962)) +
  geom_rect(aes(xmin = -54.04717,
                xmax = -48.65728,
                ymin = -30.36529,
                ymax = -23.35842),
            color = "darkred",
            fill = "red",
            alpha = 0.3,
            linewidth = 0.75) +
  theme_void() +
  theme(panel.border = element_rect(color = "black", linewidth = 1)) +
  ggview::canvas(height = 10, width = 10)

insert_map

### Mapa principal ----

ggplot() +
  geom_sf(data = continentes, color = "black", fill = "gray") +
  geom_sf(data = br, color = "black", fill = "white") +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = br, color = "black", fill = "transparent") +
  coord_sf(xlim = c(-58.5, -48.65728),
           ylim = c(-30.36529, -23.35842)) +
  theme_bw() +
  theme(panel.border = element_rect(color = "black", linewidth = 1)) +
  ggview::canvas(height = 10, width = 10)
