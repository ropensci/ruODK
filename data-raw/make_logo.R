# -----------------------------------------------------------------------------#
# Hex sticker
#
# remotes::install_github("GuangchuangYu/hexSticker")
library(hexSticker)
library(showtext)
sysfonts::font_add_google("Knewave", "knewave")
# odklogo <- here::here("man", "figures", "odk.png")
turtle <- here::here("man", "figures", "turtle.png")
ruodklogo <- here::here("man", "figures", "ruODK.png")
darkred <- "#a50b0b"
# logo s_, text p_, bg h_
hexSticker::sticker(
  # odklogo,
  turtle,
  asp = 0.684,
  s_x = 1.0, s_y = 1.05, s_width = 1.4, # s_height = 0.1,
  package = "ru", p_x = 0.5, p_y = 1, p_size = 50,
  p_family = "knewave", p_color = darkred,
  h_fill = "#aaaaaa", h_color = darkred,
  white_around_sticker = T,
  filename = ruodklogo
)
