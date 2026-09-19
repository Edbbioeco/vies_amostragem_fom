# Pacotes ----

library(sf)

library(tidyverse)

library(geobr)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade_fom.shp")

## Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

# Áreas urbanas ----

## Importar ----

areas_urb <- geobr::read_urban_area(year = 2022)

## Visualizar ----

areas_urb

ggplot() +
  geom_sf(data = areas_urb)

# Recortar para a área da FOM ----

## Recortar ----

areas_urb_fom <- areas_urb |>
  sf::st_intersection(grade |>
                        dplyr::summarise(sf::st_union(geometry)))

## Visualizar ----

areas_urb_fom

ggplot() +
  geom_sf(data = areas_urb_fom, color = "red") +
  geom_sf(data = grade, fill = "transparent")

## Exportar ----

areas_urb_fom |> sf::st_write("./gazetteers/areas_urb.shp")
