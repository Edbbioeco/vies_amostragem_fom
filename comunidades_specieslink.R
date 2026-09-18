# Pacotes ----

library(sf)

library(tidyverse)

library(readxl)

library(writexl)

# Dados ----

## Shapefile da grade ----

### Importar ----

grade <- sf::st_read("grade_fom.shp")

### Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

## Registros de ocorrência ----

### Importar ----

occ_specieslink <- readxl::read_xlsx("specieslink.xlsx")

### Visualizar ----

occ_specieslink

occ_specieslink |>  dplyr::glimpse()

# Recortar para a FOM ----

## Transformar em shapefile ----

specieslink_sf <- occ_specieslink |>
  dplyr::mutate(Order = dplyr::case_match(
    family,
    "Alligatoridae" ~ "Crocodylia",
    c("Testudinidae", "Podocnemididae", "Chelidae", "Kinosternidae",
      "Emydidae", "Cheloniidae") ~ "Testudines",
    NA ~ NA,
    .default = "Squamata"),
    .before = 1) |>
  dplyr::filter(!longitude |> is.na() &
                  !latitude |> is.na() &
                  !Order |> is.na()) |>
  dplyr::mutate(latitude = latitude |> as.numeric()) |>
  sf::st_as_sf(coords = c("longitude", "latitude"),
               crs = grade |> sf::st_crs())

specieslink_sf

ggplot() +
  geom_sf(data = specieslink_sf)

## Intersectar para a FOM ----

specieslink_sf_fom <- specieslink_sf |>
  sf::st_intersection(grade |>
                        dplyr::summarise(geometry = geometry |>
                                           sf::st_union()))

specieslink_sf_fom

ggplot() +
  geom_sf(data = grade) +
  geom_sf(data = specieslink_sf_fom)

# Data frame dos registtros ----

## Criar o data frame ----

registros_specieslik <- specieslink_sf_fom |>
  dplyr::select(Order, family, scientificname) |>
  dplyr::rename("Family" = 2,
                "Species" = 3) |>
  dplyr::mutate(decimalLongitude = sf::st_coordinates(geometry)[, 1],
                decimalLatitude = sf::st_coordinates(geometry)[, 2]) |>
  as.data.frame() |>
  dplyr::select(-geometry)

registros_specieslik

## Exportar ----

registros_specieslik |> writexl::write_xlsx("registros_specieslik.xlsx")
