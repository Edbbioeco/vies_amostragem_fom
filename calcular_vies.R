# PAcotes ----

library(tidyverse)

library(readxl)

library(sf)

library(terra)

library(sampbias)

library(performance)

library(broom)

library(flextable)

library(ggbeeswarm)

library(ggview)

library(segmented)

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

### Gráfico ----

df_pesos |>
  dplyr::mutate(Ordem = Ordem |>
                  forcats::fct_relevel(c("Crocodylia",
                                         "Testudines",
                                         "Squamata"))) |>
  ggplot(aes(Factor, Weight)) +
  ggbeeswarm::geom_quasirandom() +
  facet_wrap(~Ordem, ncol = 1, scales = "free_y") +
  labs(x = "Gazetteer") +
  theme_bw() +
  theme(axis.text = element_text(size = 20, color = "black"),
        axis.text.x = element_text(size = 15, color = "black"),
        axis.title = element_text(size = 20, color = "black"),
        legend.text = element_text(size = 20, color = "black"),
        legend.title = element_text(size = 20, color = "black"),
        legend.position = "bottom",
        strip.text = element_text(size = 30, color = "black"),
        strip.background = element_rect(color = "black",
                                        linewidth = 1),
        panel.background = element_rect(linewidth = 1,
                                        color = "black"),
        plot.title = element_text(size = 20, color = "black"),
        plot.subtitle = element_text(size = 17.5, color = "black")) +
  ggview::canvas(height = 10, width = 12)

ggsave(filename = "grafico_distribuição_pesos.png", height = 10, width = 12)

## Taxa de amostragem por MCMC ----

### Maior distância possível dentro do CEP ----

dist_fom <- grade |>
  sf::st_boundary() |>
  sf::st_cast("POINT") |>
  sf::st_coordinates() |>
  as.data.frame() |>
  dplyr::arrange(dplyr::desc(Y)) |>
  dplyr::slice(c(1, dplyr::n())) |>
  sf::st_as_sf(coords = c(1:2), crs = 4674) |>
  sf::st_distance() |>
  max() |>
  as.numeric() / 1e3

dist_fom

### Valores médios das estimativas do modelo ----

medias_vies <- purrr::map(
  modelos_vies,
  ~.x$bias_estimate |> colMeans(),
  .progress = TRUE)

medias_vies

### Criar vetor de distâncias ----

dist_seq <- seq(0, dist_fom |> as.numeric(), length.out = 1000)

dist_seq

### Data frame dos valores preditos de sampling rate ----

df_sr <- purrr::imap_dfr(
  medias_vies,
  \(medias, ordem){

    purrr::map(
      5:9,
      \(vetor){

        nome <- medias[vetor] |> names()

        tibble::tibble(
          `Distance to factor (km)` = dist_seq,
          `Sampling rate` = medias[["q"]] * exp(-medias[[nome]] * `Distance to factor (km)`),
          Factor = nome |> stringr::str_remove("w_"),
          Order = ordem)

        }
      )

    },
  .progress = TRUE)

df_sr

### Criar modelo segmentado ----

modelos_seg <- purrr::map(
  c("Crocodylia",
    "Testudines",
    "Squamata"),
  \(ordem){

    purrr::map(
      df_sr$Factor |> unique(),
      \(gaz){

        dados <- df_sr |>
          dplyr::filter(Order == ordem & Factor == gaz) |>
          dplyr::rename(sampling_rate = `Sampling rate`,
                        dist = `Distance to factor (km)`)

        lm(sampling_rate ~ dist, data = dados)

      }
    ) |>
      setNames(paste0(ordem, "_",  df_sr$Factor |> unique()))

  },
  .progress = TRUE) |>
  purrr::flatten()

modelos_seg

### Estatísticas do modelo ----

purrr::imap(
  modelos_seg,
  \(modelo, nome){

    message(nome)

    modelo |>
      summary()

    },
  .progress = TRUE)
