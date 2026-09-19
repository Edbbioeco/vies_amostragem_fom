# Pacotes ----

library(sf)

library(tidyverse)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade_fom.shp")

## Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

# Hidrelétricas ----

## Importar ----

hid <- purrr::map_dfr(
  c("Centrais_Geradoras",
    "Pequenas_Centrais",
    "Usinas_Hidrelétricas"),
  \(shp){

    arquivo <- list.files(pattern = paste0("^", shp, ".*\\.shp$"))

    sf::st_read(arquivo) |>
      dplyr::mutate(tipo = shp, .before = 1)

  },
  .progress = TRUE)
