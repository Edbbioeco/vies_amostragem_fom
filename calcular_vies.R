# PAcotes ----

library(tidyverse)

library(readxl)

library(sf)

library(terra)

library(mirai)

library(sampbias)

library(performance)

library(broom)

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
           ~ plot(.x))

## Grade da FOM ----

### Importar ----

grade <- sf::st_read("grade_fom.shp")

### Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

# Calcular viés ----

## Criar molde ----

vetor <- grade |> terra::vect()

fom_raster <- terra::rast(terra::ext(vetor),
                          resolution = (1 / 111.3194),
                          crs = "EPSG:4326") %>%
  terra::rasterize(vetor, y = ., field = 1)

fom_raster

fom_raster |> plot()

## Calcular viés por ordem ----

mirai::daemons(6)

vies_ordens <- purrr::map(
  c("Crocodylia", "Testudines", "Squamata"),
  purrr::in_parallel(

    \(ordem){

      registros |>
        dplyr::filter(Order == ordem) |>
        sampbias::calculate_bias(gaz = gaz |>
                                   purrr::map(~terra::unwrap(.x)),
                                 terrestrial = TRUE,
                                 inp_raster = fom_raster |>
                                   terra::unwrap(),
                                 restrict_sample = grade)

      },
    registros = registros,
    gaz = gaz |> purrr::map(~terra::wrap(.x)),
    fom_raster = fom_raster |> terra::wrap(),
    grade = grade

    ),
  .progress = TRUE) |>
  setNames(c("Crocodylia", "Testudines", "Squamata"))

vies_ordens

mirai::daemons(0)
