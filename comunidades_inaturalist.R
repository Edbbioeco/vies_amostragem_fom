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

inaturalist <- readr::read_csv("inaturalist.csv")

### Visualizar ----

inaturalist

inaturalist |> dplyr::glimpse()

# Recortar para a FOM ----

## Transformar em shapefile ----

inaturalist_sf <- inaturalist |>
  dplyr::filter(!longitude |> is.na() &
                  !latitude |> is.na() &
                  !taxon_order_name |> is.na()) |>
  sf::st_as_sf(coords = c("longitude", "latitude"),
               crs = grade |> sf::st_crs())

inaturalist_sf

ggplot() +
  geom_sf(data = inaturalist_sf)

## Intersectar para a FOM ----

inaturalist_sf_fom <- inaturalist_sf |>
  sf::st_intersection(grade |>
                        dplyr::summarise(geometry = geometry |>
                                           sf::st_union()))

inaturalist_sf_fom

ggplot() +
  geom_sf(data = grade) +
  geom_sf(data = inaturalist_sf_fom)

# Data frame dos registtros ----

## Criar o data frame ----

registros_inaturalist <- inaturalist_sf_fom |>
  dplyr::select(taxon_order_name, taxon_family_name, scientific_name) |>
  dplyr::rename("Order" = 1,
                "Family" = 2,
                "Species" = 3) |>
  dplyr::mutate(decimalLongitude = sf::st_coordinates(geometry)[, 1],
                decimalLatitude = sf::st_coordinates(geometry)[, 2]) |>
  as.data.frame() |>
  dplyr::select(-geometry)

registros_inaturalist

## Exportar ----

registros_inaturalist |> writexl::write_xlsx("registros_inaturalist.xlsx")
