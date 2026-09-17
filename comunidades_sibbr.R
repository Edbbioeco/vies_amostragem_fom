# Pacotes ----

library(sf)

library(tidyverse)

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

sibbr <- readr::read_csv2("sibbr.csv", quote = ";")
