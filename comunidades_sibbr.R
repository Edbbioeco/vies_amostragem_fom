# Pacotes ----

library(sf)

library(tidyverse)

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

sibbr <- readr::read_csv2("sibbr.csv", quote = ";")

### Visualizar ----

sibbr

sibbr |>  dplyr::glimpse()

### Tratar ----

sibbr_trat <- sibbr |>
  dplyr::select(c(order, family, Species,
                  decimalLongitude:decimalLatitude)) |>
  dplyr::rename("Order" = order,
                "Family" = family) |>
  dplyr::filter(!Order |> is.na() &
                  !decimalLatitude |> is.na() &
                  !decimalLongitude |> is.na()) |>
  dplyr::mutate(decimalLongitude = decimalLongitude  |>
                  stringr::str_replace(
                    "^(-?\\d{2})(\\d+)$", "\\1.\\2") |>
                  as.numeric(),
                decimalLongitude = dplyr::case_when(
                  decimalLongitude >= 0 ~ decimalLongitude * -1,
                  .default = decimalLongitude),
                decimalLatitude = case_when(stringr::str_detect(
                  as.character(decimalLatitude),
                  "^(-?[1-2])") ~ str_replace(
                    as.character(decimalLatitude),
                    "^(-?\\d{2})(\\d+)$", "\\1.\\2"),
                  stringr::str_detect(
                    as.character(decimalLatitude),
                    "^(-?[3-9])") ~ stringr::str_replace(
                      as.character(decimalLatitude),
                      "^(-?\\d{1})(\\d+)$", "\\1.\\2"),
                  TRUE ~ as.character(decimalLatitude)) |>
                  as.numeric(),
                decimalLatitude = dplyr::case_when(
                  decimalLatitude >= 0 ~ decimalLatitude * -1,
                  .default = decimalLatitude)) |>
  tidyr::drop_na()

sibbr_trat

sibbr_trat |>  dplyr::glimpse()

# Recortar para a FOM ----

## Transformar em shapefile ----

sibbr_sf <- sibbr_trat |>
  dplyr::filter(!decimalLongitude |> is.na() &
                  !decimalLatitude |> is.na() &
                  !Order |> is.na()) |>
  sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"),
               crs = grade |> sf::st_crs())

sibbr_sf

ggplot() +
  geom_sf(data = sibbr_sf)

## Intersectar para a FOM ----

sibbr_sf_fom <- sibbr_sf |>
  sf::st_intersection(grade |>
                        dplyr::summarise(geometry = geometry |>
                                           sf::st_union()))

sibbr_sf_fom

ggplot() +
  geom_sf(data = grade) +
  geom_sf(data = sibbr_sf_fom)
