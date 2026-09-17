# Pacote ----

library(geobr)

library(tidyverse)

library(sf)

library(readxl)

library(parzer)

library(writexl)

# Dados ----

## Grade -----

### Importando ----

grade <- sf::st_read("grade_fom.shp")

### Visualizando ----

grade

ggplot() +
  geom_sf(data = grade)
