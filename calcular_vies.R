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
  .progress = TRUE) |>
  setNames(c("Crocodylia", "Testudines", "Squamata"))

anovas_ordem

### Performance dos modelos ----

purrr::map(
  anovas_ordem,
  \(modelo){

    modelo |>
      performance::check_model(check = c("qq",
                                         "normality"))

    modelo |> performance::check_normality() |> print()

    modelo |> performance::check_heteroscedasticity() |> print()

    },
  .progress = TRUE)

### Estatísticas ----

anova_estatistica <- purrr::imap_dfr(
  anovas_ordem,
  \(modelo, ordem){

    modelo |>
      anova() |>
      broom::tidy() |>
      dplyr::mutate(Order = ordem,
                    .before = 1)

    },
  .progress = TRUE) |>
  dplyr::filter(term == "Factor") |>
  dplyr::select(-c(2, 4:5)) |>
  dplyr::relocate(df, .before = 4) |>
  dplyr::rename("F" = 2,
                "p value" = 4) |>
  dplyr::mutate(`p value` = dplyr::case_when(

    `p value` < 0.01 ~ "< 0.01",
    .default = `p value` |> as.character()

  ),
               `F` = `F` |> round(2))

anova_estatistica

### Tabela flextable ----

anova_estatistica_flex <- anova_estatistica |>
  flextable::flextable() |>
  flextable::align(align = "center", part = "all")

anova_estatistica_flex

anova_estatistica_flex |>
  flextable::save_as_docx(path = "tabela_anova_pesos.docx")
