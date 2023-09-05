library(sf)
library(tidyverse)
library(tigris)
library(stars)
library(rayshader)
library(MetBrewer)
library(colorspace)


#gerekli kontur datalarının okunması
data <- st_read("./kontur_population_TR_20220630.gpkg")
shapes <- st_read("./kontur_boundaries_TR_20230628.gpkg")



#bolu için filtreleme
bolu <- shapes |>
  filter(name == "Bolu") |>
  st_transform(crs = st_crs(data))


#kontrol 
bolu |>
  ggplot() +
  geom_sf()

#pop. datası ile bolu sınırlarını kesiştirme
st_bolu <- st_intersection(data, bolu)


#en boy oranını tanımlama
bb <- st_bbox(st_bolu)

sol_alt <- st_point(c(bb[["xmin"]],bb[["ymin"]])) |>
  st_sfc(crs = st_crs(data))

sag_alt <- st_point(c(bb[["xmax"]],bb[["ymin"]])) |>
  st_sfc(crs = st_crs(data))

#plotting noktaları kontrol
bolu |>
  ggplot() +
  geom_sf() +
  geom_sf(data = sol_alt) +
  geom_sf(data = sag_alt, color = "red")

genislik <- st_distance(sol_alt,sag_alt)

sol_ust <- st_point(c(bb[["xmin"]],bb[["ymax"]])) |>
  st_sfc(crs = st_crs(data))

yukseklik <- st_distance(sol_alt,sol_ust)


#genislik ve yukseklikten hangisinin uzun olduğunun belirlenmesi
if (genislik > yukseklik) {
  w_ratio <- 1
  h_ratio <- yukseklik / genislik
} else {
    h_ratio <- 1
    w_ratio <- genislik / yukseklik
}

#matrixe cevirme

size <- 5000

bolu_rast <- st_rasterize(st_bolu,
                          nx = floor(size * w_ratio),
                          ny = floor(size * h_ratio))
 
mat <- matrix(bolu_rast$population,
              nrow = floor(size * w_ratio),
              ncol = floor(size * h_ratio))

#renk paleti olusturma
renk_paleti <- met.brewer("OKeeffe2")
swatchplot(renk_paleti)

texture <- grDevices::colorRampPalette(renk_paleti)(256)
swatchplot(texture)

# 3d Xquartz bloğu
rgl::close3d()

mat |>
  height_shade(texture = texture) |>
  plot_3d(heightmap = mat,
          zscale = 100/5,
          solid = FALSE,
          shadowdepth = 0)

render_camera(theta = 5, phi = 60, zoom = 1)

gorsel <- "images/finalv2_plot.png"

{
  baslama_zamani <- Sys.time()
  cat(crayon::cyan(baslama_zamani), "\n")
  if (!file.exists(gorsel)) {
    png::writePNG(matrix(1), target = gorsel)
  }
  render_highquality(
    filename = gorsel,
    interactive = FALSE,
    lightdirection = 280,
    lightaltitude = c(20,80),
    lightcolor = c(renk_paleti[2], "white"),
    lightintensity = c(600,100),
    samples = 450,
    width = 6000,
    height = 6000
  )
  bitis_zamani <- Sys.time()
  fark <- bitis_zamani - baslama_zamani
  cat(crayon::cyan(fark), "\n")
}
