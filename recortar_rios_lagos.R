# Pacotes ----

library(sf)

library(tidyverse)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade_fom.shp")

## Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

# Rios e Lagos ----

## Importar ----

rioslagos <- sf::st_read("GEOFT_BHO_REF_RIO.shp")

## Visualizar ----

rioslagos

ggplot() +
  geom_sf(data = rioslagos)

# Recortar para a área da FOM ----

## Recortar ----

rios_fom <- rioslagos |>
  sf::st_transform(crs = grade |> sf::st_crs()) |>
  sf::st_intersection(grade |>
                        dplyr::summarise(sf::st_union(geometry)))

## Visualizar ----

rios_fom

ggplot() +
  geom_sf(data = rios_fom, color = "blue") +
  geom_sf(data = grade, fill = "transparent")

## Exportar ----

dir.create("./gazetteers")

rios_fom |> sf::st_write("./gazetteers/rios.shp")
