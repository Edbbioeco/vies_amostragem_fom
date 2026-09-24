# Pacotes ----

library(sf)

library(tidyverse)

library(sf)

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

gbif <- readr::read_tsv("gbif.csv",
                        quote = "",
                        na = "")

### Visualizar ----

gbif

gbif |> dplyr::glimpse()

# Recortar para a FOM ----

## Transformar em shapefile ----

gbif_sf <- gbif |>
  sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"),
               crs = grade |> sf::st_crs())

gbif_sf

ggplot() +
  geom_sf(data = gbif_sf)

## Intersectar para a grade da FOM ----

gbif_sf_fom <- gbif_sf |>
  sf::st_intersection(grade |>
                        dplyr::summarise(geometry = geometry |>
                                           sf::st_union()))

gbif_sf_fom

ggplot() +
  geom_sf(data = grade) +
  geom_sf(data = gbif_sf_fom)

## Criar data frame dos registros ----

gbif_registros <- gbif_sf_fom |>
  as.data.frame() |>
  dplyr::select(order, family, species) |>
  dplyr::filter(!order |> is.na()) |>
  dplyr::rename("Order" = 1,
                "Family" = 2,
                "Species" = 3) |>
  dplyr::bind_cols(gbif_sf_fom |>
                     dplyr::filter(!order |> is.na()) |>
                     sf::st_coordinates() |>
                     as.data.frame() |>
                     dplyr::rename("decimalLongitude" = 1,
                                   "decimalLatitude" = 2))

gbif_registros

## Exportar registros ----

gbif_registros |> writexl::write_xlsx("registros_gbif.xlsx")
