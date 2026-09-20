# PAcotes ----

library(tidyverse)

library(readxl)

library(sf)

library(terra)

library(sampbias)

library(performance)

library(ggview)

library(segmented)

library(flextable)

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

## Visualizar ----

registros

registros |> dplyr::glimpse()

# Gazetteers ----

## Importar ----

gaz <- purrr::map(
  list.files(path = "./gazetteers/",
             pattern = ".shp$",
             full.names = TRUE),
  ~sf::st_read(.x) |>
    sf::st_transform(crs = 4674) |>
    terra::vect(),
  .progress = TRUE) |>
  setNames(c("Urban areas",
             "Hidreletric plants",
             "Rivers",
             "Highways",
             "Conservation units"))

## Visualizar ----

gaz

purrr::map(gaz,
           ~ plot(x))

# Calcular viés ----

## Calcular viés por ordem ----

vies_ordens <- purrr::map(
  c("Crocodylia", "Testudines", "Squamata"),
  purrr::in_parallel(

    \(ordem){

      registros |>
        dplyr::filter(Order == ordem) |>
        sampbias::calculate_bias(gaz = gaz,
                                 res = (1 / 111.3194),
                                 terrestrial = TRUE)

      }

    ),
  .progress = TRUE)

vies_ordens
