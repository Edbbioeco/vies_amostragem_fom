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
