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
