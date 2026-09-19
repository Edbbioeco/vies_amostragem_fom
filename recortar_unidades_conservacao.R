# Pacotes ----

library(sf)

library(tidyverse)

library(geobr)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade_fom.shp")
