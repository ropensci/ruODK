# -----------------------------------------------------------------------------#
# Hex sticker
#
# remotes::install_github("GuangchuangYu/hexSticker")
# library(hexSticker)
# library(showtext)
sysfonts::font_add_google("Knewave", "knewave")
# sysfonts::font_add_google("Prosto One", "prosto")
# sysfonts::font_add_google("Concert One", "concert")
turtle <- here::here("man", "figures", "turtle.png")
ruodklogo <- here::here("man", "figures", "ruODK.png")
darkred <- "#a50b0b"
# logo s_, text p_, bg h_
hexSticker::sticker(
  turtle,
  # asp = 0.684, dpi = 300,
  s_x = 1.0, s_y = 1.00, s_width = 1.1, # s_height = 0.1,
  package = "ruODK", p_x = 1, p_y = 0.43, p_size = 24,
  p_family = "knewave", p_color = darkred,
  h_fill = "#aaaaaa", h_color = darkred,
  # url = "docs.ropensci.org/ruODK", u_size = 4, u_color = "#ffffff",
  white_around_sticker = T,
  filename = ruodklogo
)
