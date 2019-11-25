# ODK Central example data
ruODK::ru_setup(
  svc = Sys.getenv("ODKC_TEST_SVC"),
  un = Sys.getenv("ODKC_TEST_UN"),
  pw = Sys.getenv("ODKC_TEST_PW")
)

fq_svc <- ruODK::odata_service_get()
fq_meta <- ruODK::odata_metadata_get()
fq_fs <- ruODK::form_schema()
fq_raw <- ruODK::odata_submission_get(table = fq_svc$name[1], parse = FALSE)
fq_raw_strata <- ruODK::odata_submission_get(table = fq_svc$name[2], parse = FALSE)
fq_raw_taxa <- ruODK::odata_submission_get(table = fq_svc$name[3], parse = FALSE)
fq_data <- ruODK::odata_submission_get(table = fq_svc$name[1], parse = TRUE)
fq_data_strata <- ruODK::odata_submission_get(
  table = fq_svc$name[2], parse = TRUE
) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))
fq_data_taxa <- ruODK::odata_submission_get(
  table = fq_svc$name[3], parse = TRUE
) %>%
  dplyr::rename(lon = x6, lat = x7, alt = x8) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))

usethis::use_data(fq_svc, overwrite = T)
usethis::use_data(fq_meta, overwrite = T)
usethis::use_data(fq_raw, overwrite = T)
usethis::use_data(fq_raw_strata, overwrite = T)
usethis::use_data(fq_raw_taxa, overwrite = T)
usethis::use_data(fq_data, overwrite = T)
usethis::use_data(fq_data_strata, overwrite = T)
usethis::use_data(fq_data_taxa, overwrite = T)

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
