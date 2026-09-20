# PAcotes ----

library(tidyverse)

library(readxl)

library(sf)

library(sampbias)

library(performance)

library(ggview)

library(segmented)

library(flextable)

library(terra)

library(tidyterra)

library(spdep)

# Registros de ocorrência ----

## Importar ----

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
  .progress = TRUE) |>
  dplyr::filter(!decimalLongitude |> is.na() &
                  !decimalLatitude |> is.na())

# Gazetteers ----

## Importar ----

gaz <- purrr::map(
  list.files(path = "./gazetteers/",
             pattern = ".shp$",
             full.names = TRUE),
  sf::st_read,
  .progress = TRUE) |>
  setNames(c("Urban areas",
             "Hidreletric plants",
             "Rivers",
             "Highways",
             "Conservation units"))

## Visualizar ----

gaz

purrr::map(gaz,
           ~ ggplot() + geom_sf(data = .x))
