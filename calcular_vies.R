# PAcotes ----

library(tidyverse)

library(readxl)

library(sf)

library(terra)

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
                          resolution = (10 / 111.3194),
                          crs = "EPSG:4326") %>%
  terra::rasterize(vetor, y = ., field = 1)

fom_raster

fom_raster |> plot()

## Calcular viés por ordem ----

vies_ordens <- purrr::map(
  c("Crocodylia", "Testudines", "Squamata"),
  purrr::in_parallel(

    \(ordem){

      registros |>
        dplyr::filter(Order == ordem) |>
        sampbias::calculate_bias(gaz = gaz,
                                 inp_raster = fom_raster,
                                 res = (10 / 111.3194),
                                 terrestrial = TRUE)

      }

    ),
  .progress = TRUE) |>
  setNames(c("Crocodylia", "Testudines", "Squamata"))

vies_ordens

## Salvar modelos ----

purrr::imap(
  vies_ordens,
  \(modelo, ordem){

    modelo$summa$extent <- modelo$summa$extent |> as.vector()

    modelo$occurrences <- modelo$occurrences |> terra::wrap()

    modelo$distance_rasters <- modelo$distance_rasters |> terra::wrap()

    modelo |>
      readr::write_rds(file = paste0("modelo_vies_", ordem, ".rds"))

    },
  .progress = TRUE)

## Importar modelos ----

modelos_vies <- purrr::map(
  c("Crocodylia", "Testudines", "Squamata"),
  \(ordem){

    modelo <- readr::read_rds(file = paste0("modelo_vies_", ordem, ".rds"))

    modelo$summa$extent <- modelo$summa$extent |> terra::ext()

    modelo$occurrences <- modelo$occurrences |> terra::unwrap()

    modelo$distance_rasters <- modelo$distance_rasters |> terra::unwrap()

    modelo

    },
  .progress = TRUE) |>
  setNames(c("Crocodylia", "Testudines", "Squamata"))

modelos_vies

## Pesos por modelo ----

### Criar data frame ----

df_pesos <- purrr::imap_dfr(
  modelos_vies,
  \(modelo, ordem){

    modelo$bias_estimate |>
      tidyr::pivot_longer(cols = dplyr::contains("w_"),
                          names_to = "Factor",
                          values_to = "Weight") |>
      dplyr::mutate(Factor = Factor |>
                      stringr::str_remove("w_") |>
                      stringr::str_replace_all("\\.", " "),
                    Ordem = ordem)

  },
  .progress = TRUE)

df_pesos

### Criar modelo ANOVA ----

anovas_ordem <- purrr::map(
  c("Crocodylia", "Testudines", "Squamata"),
  \(ordem){

    lm(Weight ~ Factor,
       data = df_pesos |>
         dplyr::filter(Ordem == ordem))

    },
  .progress = TRUE)

anovas_ordem
