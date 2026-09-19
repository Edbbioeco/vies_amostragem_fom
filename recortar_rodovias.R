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

# Rodovias ----

## Importar ----

rodovias <- purrr::map_dfr(
  c("FEDERAL", "ESTADUAL"),
  \(tipo){

    sf::st_read(paste0("GEOFT_TRECHO_RODOVIARIO_",
                       tipo,
                       ".shp")) |>
      dplyr::mutate(Tipo = tipo |> stringr::str_to_title())

    },
  .progress = TRUE)

## Visualizar ----

rodovias

ggplot() +
  geom_sf(data = rodovias)

# Recortar rodovias para a área da FOM ----

## Recortar ----

rodovias |>
  sf::st_intersection(grade |>
                        dplyr::summarise(sf::st_union(geometry)))
