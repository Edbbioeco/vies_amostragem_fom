# Pacotes ----

library(tidyverse)

library(rnaturalearth)

library(sf)

library(cowplot)

library(ggview)

# Dados ----

## Shapefile dos estados do Brasil ----

### Importar ----

br <- rnaturalearth::ne_states(country = "Brazil")

### Visualizar ----

br

ggplot() +
  geom_sf(data = br, color = "black")

## Continentes ----

### Importar ----

continentes <- rnaturalearth::ne_countries(scale = "large")

### Visualizar ----

continentes

ggplot() +
  geom_sf(data = continentes, color = "black") +
  geom_sf(data = br, color = "black", fill = "white")

## FOM ----

### Importar ----

fom <- sf::st_read("fom.shp")

### Visualizar ----

fom

ggplot() +
  geom_sf(data = br, color = "black") +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen")

## Grade ----

### Importar ----

grade <- sf::st_read("grade_fom.shp")

### Visualizar ----

grade

ggplot() +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = grade, color = "black", fill = "transparent")

# Mpas ----

## Insert map ----

insert_map <- ggplot() +
  geom_sf(data = continentes, color = "black", fill = "gray") +
  geom_sf(data = br, color = "black", fill = "white") +
  geom_sf(data = fom, color = "forestgreen", fill = "forestgreen") +
  geom_sf(data = br, color = "black", fill = "transparent") +
  coord_sf(xlim = c(-72.98681, -35),
           ylim = c(-32.75108, 4.26962)) +
  geom_rect(aes(xmin = -54.04717,
                xmax = -48.65728,
                ymin = -30.36529,
                ymax = -23.35842),
            color = "darkred",
            fill = "red",
            alpha = 0.3,
            linewidth = 0.75) +
  theme_void() +
  theme(panel.border = element_rect(color = "black",
                                    linewidth = 1),
        panel.background = element_rect(fill = "white")) +
  ggview::canvas(height = 10, width = 10)

insert_map

### Mapa principal ----

mapa_geral <- ggplot() +
  geom_sf(data = continentes,
          aes(color = "South America", fill = "South America"),
          linewidth = 1) +
  geom_sf(data = br,
          aes(color = "Brazil", fill = "Brazil"),
          linewidth = 1) +
  geom_sf(data = fom,
          aes(color = "AMF", fill = "AMF")) +
  geom_sf(data = grade,
          aes(color = "Grid", fill = "Grid"),
          linewidth = 0.75) +
  geom_sf(data = br, color = "black", fill = "transparent", linewidth = 1) +
  scale_color_manual(values = c("South America" = "black",
                                "Brazil" = "black",
                                "AMF" = "forestgreen",
                                "Grid" = "darkred"),
                     breaks = c("South America",
                                "Brazil",
                                "AMF",
                                "Grid")) +
  scale_fill_manual(values = c("South America" = "grey",
                               "Brazil" = "white",
                               "AMF" = "forestgreen",
                               "Grid" = "transparent"),
                     breaks = c("South America",
                                "Brazil",
                                "AMF",
                                "Grid")) +
  coord_sf(xlim = c(-58.5, -48.65728),
           ylim = c(-30.36529, -23.35842),
           label_graticule = "NSEW") +
  labs(fill = NULL,
       color = NULL) +
  theme_bw() +
  theme(axis.text = element_text(size = 20, color = "black"),
        legend.text = element_text(size = 20, color = "black"),
        legend.position = "bottom",
        panel.border = element_rect(color = "black", linewidth = 1)) +
  ggview::canvas(height = 10, width = 10)

mapa_geral

## Mapa final ----

mapa_geral |>
  cowplot::ggdraw() +
  cowplot::draw_plot(insert_map,
                     x = 0.1,
                     y = 0.475,
                     height = 0.275,
                     width = 0.275) +
  ggview::canvas(height = 10, width = 10)

ggsave(filename = "mapa_grid.png",
       height = 10, width = 10)
