# Pacote ----

library(geobr)

library(tidyverse)

library(sf)

library(readxl)

library(parzer)

library(writexl)

# Dados ----

## Grade -----

### Importar ----

grade <- sf::st_read("grade_fom.shp")

### Visualizar ----

grade

ggplot() +
  geom_sf(data = grade)

## Registros das espécies -----

### Importar ----

sps <- readxl::read_xlsx("DADOS COPILADOS DA FOM 2026.xlsx")

### Visualizar ----

sps

sps |> dplyr::glimpse()

### Tratar ----

sps_trat <- sps |>
  tidyr::pivot_longer(cols = dplyr::where(is.numeric),
                      values_to = "Presence",
                      names_to = "Local") |>
  dplyr::filter(Presence == 1)

sps_trat
