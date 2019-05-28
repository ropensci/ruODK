# ODK Central example data
if (file.exists("~/.Rprofile")) source("~/.Rprofile")
data_url <- "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc"
fq_meta <- get_metadata(data_url)
fq_raw <- get_submissions(data_url)
usethis::use_data(fq_meta, overwrite = T)
usethis::use_data(fq_raw, overwrite = T)


# Hex sticker
# remotes::install_github("GuangchuangYu/hexSticker")
library(hexSticker)
library(showtext)
sysfonts::font_add_google("Knewave", "knewave")
odklogo <- here::here("man", "figures", "odk.png")
ruodklogo <- here::here("man", "figures", "ruODK.png")
darkred <- "#a50b0b"
hexSticker::sticker(odklogo, s_x=1, s_y=.75, s_width=0.7, s_height=0.7, # logo
                    package="ruODK", p_size=36, p_family="knewave", p_color=darkred, # text
                    h_fill="#d81c00", h_color=darkred, # bg
                    filename=ruodklogo)
