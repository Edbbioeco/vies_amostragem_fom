# PAcotes ----

library(readxl)

library(tidyverse)

library(sf)

library(sampbias)

library(performance)

library(ggview)

library(segmented)

library(flextable)

library(terra)

library(tidyterra)

library(spdep)

# Registros de ocorrência ----

## Importar ----

registros <- purrr::map_dfr(
  c("gbif",
    "levantamento",
    "specieslink",
    "sibbr",
    "inaturalist",
    "herpetohelp"),
  \(fonte){

    readxl::read_xlsx(paste0("registros_", fonte, ".xlsx"))

  },
  .progress = TRUE)
