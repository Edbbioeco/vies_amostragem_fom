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

# Grade ----

## Recortar a FOM apenas para o Sul ----

fom_recortada <- fom |>
  sf::st_join(br |> dplyr::filter(name_region == "Sul")) |>
  dplyr::filter(!name_region |> is.na())

fom_recortada

ggplot() +
  geom_sf(data = br, color = "black") +
  geom_sf(data = fom_recortada, color = "forestgreen", fill = "forestgreen",
          alpha = 0.3)

# Grade ----

## Gerar a grade -----

grade <- fom_recortada |>
  sf::st_make_grid(cellsize = (10 / 111.3194)) |>
  sf::st_sf() |>
  sf::st_join(fom_recortada) |>
  dplyr::filter(!id1 |> is.na()) |>
  dplyr::mutate(ID = paste0("c", dplyr::row_number()))

grade

ggplot() +
  geom_sf(data = fom_recortada, color = "forestgreen", fill = "forestgreen",
          alpha = 0.3) +
  geom_sf(data = grade, color = "darkred", fill = NA)
