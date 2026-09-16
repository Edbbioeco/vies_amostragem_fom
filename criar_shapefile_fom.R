# Pacotes ----

library(geobr)

library(sf)

library(tidyverse)

# Dados ----

## Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

### Visualizando ----

br

ggplot() +
  geom_sf(data = br, color = "black")
