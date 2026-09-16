# Pacotes ----

library(geobr)

library(sf)

library(tidyverse)

# Dados ----

## Brasil ----

### Importar ----

br <- geobr::read_state()

### Visualizando ----

br

ggplot() +
  geom_sf(data = br, color = "black")
