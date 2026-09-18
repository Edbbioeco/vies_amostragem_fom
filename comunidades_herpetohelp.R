# Pacotes ----

library(sf)

library(tidyverse)

library(readxl)

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

herpetohelp <- readxl::read_xlsx("herptohelp.xlsx",,
                                 sheet = 2)

### Visualizar ----

herpetohelp

herpetohelp |> dplyr::glimpse()

# Recortar para a FOM ----

## Transformar em shapefile ----

herpetohelp_sf <- herpetohelp |>
  dplyr::mutate(Order = dplyr::case_match(
    Família,
    "Alligatoridae" ~ "Crocodylia",
    c("Testudinidae", "Podocnemididae", "Chelidae", "Kinosternidae",
      "Emydidae", "Cheloniidae") ~ "Testudines",
    NA ~ NA,
    .default = "Squamata"),
    .before = 1) |>
  dplyr::filter(Grupo == "Répteis") |>
  dplyr::filter(!`Longitude no mapa (SIRGAS 2000)` |> is.na() &
                  !`Latitude no mapa (SIRGAS 2000)` |> is.na() &
                  !Order |> is.na()) |>
  dplyr::mutate(`Latitude no mapa (SIRGAS 2000)` = `Latitude no mapa (SIRGAS 2000)` |> as.numeric(),
                Espécie = Espécie |>
                  stringr::str_replace("^(\\S+\\s+\\S+)\\s+\\S+(.*)",
                                       "\\1\\2")) |>
  sf::st_as_sf(coords = c("Longitude no mapa (SIRGAS 2000)", "Latitude no mapa (SIRGAS 2000)"),
               crs = grade |> sf::st_crs())

herpetohelp_sf

ggplot() +
  geom_sf(data = herpetohelp_sf)

## Intersectar para a FOM ----

herpetohelp_sf_fom <- herpetohelp_sf |>
  sf::st_intersection(grade |>
                        dplyr::summarise(geometry = geometry |>
                                           sf::st_union()))

herpetohelp_sf_fom

ggplot() +
  geom_sf(data = grade) +
  geom_sf(data = herpetohelp_sf_fom)

# Data frame dos registtros ----

## Criar o data frame ----

registros_herpetohelp <- herpetohelp_sf_fom |>
  dplyr::select(Order, Família, Espécie) |>
  dplyr::rename("Family" = 2,
                "Species" = 3) |>
  dplyr::mutate(decimalLongitude = sf::st_coordinates(geometry)[, 1],
                decimalLatitude = sf::st_coordinates(geometry)[, 2]) |>
  as.data.frame() |>
  dplyr::select(-geometry)

registros_herpetohelp

## Exportar ----

registros_herpetohelp |> writexl::write_xlsx("registros_herpetohelp.xlsx")
