# Pacotes ----

library(sf)

library(tidyverse)

# Grade da FOM ----

## Importar ----

grade <- sf::st_read("grade_fom.shp")
