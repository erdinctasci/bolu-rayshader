library(magick)
library(MetBrewer)
library(colorspace)
library(ggplot2)
library(glue)
library(stringr)

img <- image_read("images/finalv2_plot.png")

colors <- met.brewer("OKeeffe2")
swatchplot(colors)

text_color <- darken(colors[7], .25)
swatchplot(text_color)

annot <- glue("This map uses 400-meter hexagons to visualize the population density of Bolu, ", 
              "with darker colors representing higher densities. ","The hexagons are about 0.4 ",
              "kilometers in size, which is a common unit of measurement for population density maps.") |> 
  str_wrap(55)

img |> 
  image_crop(gravity = "center",
             geometry = "6000x3500+0-150") |> 
  image_annotate("Bolu Population Density",
                 gravity = "northwest",
                 location = "+200+100",
                 color = text_color,
                 size = 200,
                 weight = 700,
                 font = "El Messiri") |> 
  image_annotate(annot,
                 gravity = "west",
                 location = "+200-950",
                 color = text_color,
                 size = 105,
                 font = "El Messiri") |> 
  image_annotate(glue("Graphic by Erdinç Taşçı | linkedin.com/in/erdinc-tasci | github.com/erdinctasci | ",
                      "Data: Kontur Population (Released 2022-06-30)"),
                 gravity = "south",
                 location = "0+500",
                 font = "El Messiri",
                 color = alpha(text_color, .5),
                 size = 70) |> 
  image_write("images/titled_final_plotv2.png")

