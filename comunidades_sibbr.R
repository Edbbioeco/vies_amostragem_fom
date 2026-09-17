# Pacotes ----

library(sf)

library(tidyverse)

library(writexl)

# Dados ----

## Shapefile da grade ----

### Importar ----

grade <- sf::st_read("grade_fom.shp")
