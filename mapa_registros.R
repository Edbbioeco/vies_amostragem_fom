# Pacotes ----

library(geobr)

library(tidyverse)

library(sf)

library(readxl)

library(ggview)

# Dados ----

## Shapefile dos estados do Brasil ----

### Importar ----

br <- geobr::read_state(year = 2025)

### Visualizar ----

br

ggplot() +
  geom_sf(data = br)

## Florestas Ombrófilas Mistas ----

### Importar ----

fom <- sf::st_read("fom.shp")

### Visualizar ----

fom

ggplot() +
  geom_sf(data = br) +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen")

## Registros de ocorrÊncia ----

### Importar ----

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
  .progress = TRUE) |>
  dplyr::filter(!decimalLongitude |> is.na() &
                  !decimalLatitude |> is.na() &
                  !Species %in% c("Anolis philopunctatus",
                                  "Lygophis lineatus",
                                  "Dipsas indica",
                                  "Xenodon biligonigerus",
                                  "Caiman crocodylus",
                                  "Eunectes murinus",
                                  "Eunectes notaeus",
                                  "Dermochelys coriacea",
                                  "Amalosia queenslandia",
                                  "Diploglossus fasciatus",
                                  "Dipsas incerta",
                                  "Hydrodynastes gigas",
                                  "Pseudoboa neuwiedii",
                                  "Xenopholis scalaris",
                                  "Lepidodactylus lugubris",
                                  "Rhinoclemmys punctularia",
                                  "Arthrosaura reticulata",
                                  "Heterodactylus imbricatus",
                                  "Iguana iguana",
                                  "Polychrus marmoratus",
                                  "Chatogekko amazonicus",
                                  "Gonatodes humeralis",
                                  "Cnemidophorus cryptus",
                                  "Cnemidophorus gramivagus",
                                  "Kentropyx calcarata",
                                  "Tropidurus oreadicus",
                                  "Tropidurus torquatus",
                                  "Uranoscodon superciliosus",
                                  "Bothrops atrox",
                                  "Caretta caretta",
                                  "Chelonia mydas",
                                  "Lepidochelys olivacea",
                                  "Podocnemis expansa",
                                  "Podocnemis sextuberculata",
                                  "Podocnemis unifilis",
                                  "Mabuya mabouya",
                                  "Trachemys scripta",
                                  "Anilius scytale",
                                  "Dactyloa punctata",
                                  "Norops ortonii",
                                  "Corallus hortulana",
                                  "Dendrophidion dendrophis",
                                  "Leptophis ahaetulla",
                                  "Mastigodryas boddaerti",
                                  "Oxybelis aeneus",
                                  "Spilotes sulphureus",
                                  "Echinanthera melanostigma",
                                  "Erythrolamprus aesculapii",
                                  "Erythrolamprus breviceps",
                                  "Erythrolamprus miliaris",
                                  "Erythrolamprus poecilogyrus",
                                  "Erythrolamprus typhlus",
                                  "Helicops leopardinus",
                                  "Leptodeira annulata",
                                  "Phalotris lativittatus",
                                  "Thamnodynastes pallidus",
                                  "Micrurus frontalis",
                                  "Micrurus lemniscatus",
                                  "Chelonoidis carbonarius"))

### Visualizar ----

registros

registros |> dplyr::glimpse()

### Transformar um shapefile ----

registros_sf <- registros |>
  dplyr::filter(!decimalLongitude |> is.na() &
                  !decimalLatitude |> is.na()) |>
  sf::st_as_sf(coords = paste0("decimal",
                               c("Longitude",
                                 "Latitude")),
               crs = fom |> sf::st_crs())

registros_sf

ggplot() +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = registros_sf, alpha = 0.5, size = 1)

# Mapa dos registros ----

## Criar mapa ----

ggplot() +
  geom_sf(data = br,
          aes(color = "Brazil", fill = "Brazil"),
          linewidth = 1) +
  geom_sf(data = fom,
          aes(color = "FOM", fill = "FOM")) +
  geom_sf(data = br, color = "black", fill = "transparent",
          linewidth = 1) +
  geom_sf(data = registros_sf,
          aes(color = "Species records", fill = "Species records"),
          shape = 21,
          size = 2) +
  scale_color_manual(values = c("Brazil" = "black",
                                "FOM" = "forestgreen",
                                "Species records" = "black"),
                     breaks = c("Brazil", "FOM", "Species records")) +
  scale_fill_manual(values = c("Brazil" = "gray",
                               "FOM" = "forestgreen",
                               "Species records" = "black"),
                     breaks = c("Brazil", "FOM", "Species records")) +
  coord_sf(xlim = c(-54.03497, -48.34859),
           ylim = c(-30.25525, -23.36159),
           label_graticule = "NSWE") +
  labs(color = NULL,
       fill = NULL) +
  theme_bw() +
  theme(axis.text = element_text(size = 20, color = "black"),
        legend.text = element_text(size = 20, color = "black"),
        legend.position = "bottom",
        panel.border = element_rect(color = "black", linewidth = 1)) +
  ggview::canvas(height = 10, width = 12)

## Exportar ----

ggsave(filename = "mapa_registros.png",
       height = 10, width = 12)
