# Pacotes ----

library(geobr)

library(tidyverse)

library(sf)

library(readxl)

library(ggview)

# Dados ----

## Shapefile dos estados do Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

### Visualizar ----

br

ggplot() +
  geom_sf(data = br)

## Florestas Ombrófilas Mistas ----

### Importar ----

fom <- sf::st_read("fom.shp")

### Visualizar ----

fom

ggplot() +
  geom_sf(data = br) +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen")

## Registros de ocorrÊncia ----

### Importar ----

registros <- purrr::map_dfr(
  c("gbif",
    "levantamento",
    "specieslink",
    "sibbr",
    "inaturalist",
    "herpetohelp"),
  \(fonte){

    readxl::read_xlsx(paste0("registros_", fonte, ".xlsx"))

    },
  .progress = TRUE)

### Visualizar ----

registros

registros |> dplyr::glimpse()

### Transformar um shapefile ----

registros_sf <- registros |>
  dplyr::filter(!decimalLongitude |> is.na() &
                  !decimalLatitude |> is.na()) |>
  sf::st_as_sf(coords = paste0("decimal",
                               c("Longitude",
                                 "Latitude")),
               crs = fom |> sf::st_crs())

registros_sf

ggplot() +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = registros_sf, alpha = 0.5, size = 1)
