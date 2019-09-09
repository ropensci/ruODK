# ODK Central example data
ruODK::ru_setup(
  svc = "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-2_1558575936.svc",
  un = Sys.getenv("ODKC_TEST_UN"),
  pw = Sys.getenv("ODKC_TEST_PW")
)

fq_svc <- ruODK::odata_service_get()
fq_meta <- ruODK::odata_metadata_get()
fq_raw <- ruODK::odata_submission_get()

usethis::use_data(fq_svc, overwrite = T)
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
# logo s_, text p_, bg h_
hexSticker::sticker(odklogo,
  s_x = 1.2, s_y = 0.9, s_width = 0.7, s_height = 0.9,
  package = "ru", p_x = 0.45, p_y = 1, p_size = 40,
  p_family = "knewave", p_color = "#ffaa77",
  h_fill = "#d81c00", h_color = darkred,
  filename = ruodklogo
)
