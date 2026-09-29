# Pacotes ----

library(geobr)

library(tidyverse)

library(sf)

library(cowplot)

library(ggview)

# Dados ----

## Shapefile dos estados do Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

