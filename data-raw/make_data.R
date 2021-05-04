# -----------------------------------------------------------------------------#
# ODK Central example data
#
library(ruODK)
ruODK::ru_setup(
  svc = Sys.getenv("ODKC_TEST_SVC"),
  un = Sys.getenv("ODKC_TEST_UN"),
  pw = Sys.getenv("ODKC_TEST_PW"),
  odkc_version = Sys.getenv("ODKC_TEST_VERSION"),
  tz = Sys.getenv("RU_TIMEZONE")
)

# Used in vignette odata-api
t <- fs::dir_create("attachments")
fq_svc <- ruODK::odata_service_get()
fq_meta <- ruODK::odata_metadata_get()
fq_fs <- ruODK::form_schema(odkc_version = ruODK::get_test_odkc_version())
fq_raw <- ruODK::odata_submission_get(table = fq_svc$name[1], parse = FALSE)
fq_raw_strata <- ruODK::odata_submission_get(table = fq_svc$name[2], parse = FALSE)
fq_raw_taxa <- ruODK::odata_submission_get(table = fq_svc$name[3], parse = FALSE)

fq_data <- ruODK::odata_submission_get(
  table = fq_svc$name[1], wkt = TRUE, parse = T, odkc_version = get_test_odkc_version()
)
fq_data_strata <- ruODK::odata_submission_get(
  table = fq_svc$name[2], wkt = TRUE, odkc_version = get_test_odkc_version()
) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))
fq_data_taxa <- ruODK::odata_submission_get(
  table = fq_svc$name[3], wkt = TRUE, odkc_version = get_test_odkc_version()
) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))

# Geofields
geo_fs <- form_schema(
  pid = get_test_pid(),
  fid = get_test_fid_wkt(),
  url = get_test_url(),
  un = get_test_un(),
  pw = get_test_pw(),
  odkc_version = get_test_odkc_version()
)

geo_gj_raw <- odata_submission_get(
  pid = get_test_pid(),
  fid = get_test_fid_wkt(),
  url = get_test_url(),
  un = get_test_un(),
  pw = get_test_pw(),
  odkc_version = get_test_odkc_version(),
  parse = FALSE,
  wkt = FALSE
)
geo_gj <- odata_submission_get(
  pid = get_test_pid(),
  fid = get_test_fid_wkt(),
  url = get_test_url(),
  un = get_test_un(),
  pw = get_test_pw(),
  odkc_version = get_test_odkc_version(),
  parse = TRUE,
  wkt = FALSE
)
geo_wkt_raw <- odata_submission_get(
  pid = get_test_pid(),
  fid = get_test_fid_wkt(),
  url = get_test_url(),
  un = get_test_un(),
  pw = get_test_pw(),
  odkc_version = get_test_odkc_version(),
  parse = FALSE,
  wkt = TRUE
)
geo_wkt <- odata_submission_get(
  pid = get_test_pid(),
  fid = get_test_fid_wkt(),
  url = get_test_url(),
  un = get_test_un(),
  pw = get_test_pw(),
  odkc_version = get_test_odkc_version(),
  parse = TRUE,
  wkt = TRUE
)

# Used in vignette rest-api
fq_project_list <- ruODK::project_list()
fq_project_detail <- ruODK::project_detail()
fq_form_list <- ruODK::form_list()
fq_form_xml <- ruODK::form_xml(parse = FALSE)
fq_form_schema <- ruODK::form_schema(odkc_version = get_test_odkc_version())
fq_form_detail <- ruODK::form_detail()


# V7 form schema
# This requires access to an ODK Central v7 server
# fs_v7_raw <- ruODK::form_schema(odkc_version = 0.7, parse = FALSE)
# fs_v7 <- ruODK::form_schema_parse(fs_v7_raw)
# usethis::use_data(fs_v7_raw, overwrite = T)
# usethis::use_data(fs_v7, overwrite = T)

fid <- ruODK::get_test_fid()
fid_csv <- fs::path(t, glue::glue("{fid}.csv"))
fid_csv_tae <- fs::path(t, glue::glue("{fid}-taxon_encounter.csv"))
fid_csv_veg <- fs::path(t, glue::glue("{fid}-vegetation_stratum.csv"))

se <- ruODK::submission_export(local_dir = ".", overwrite = FALSE, verbose = TRUE)
f <- unzip(se, exdir = t)
# Prepend attachments with media/ to turn into relative file paths
fq_zip_data <- fid_csv %>%
  readr::read_csv(na = c("", "NA", "na")) %>%
  # form uses "na" for NA
  janitor::clean_names(.) %>%
  dplyr::mutate(id = meta_instance_id) %>%
  ruODK::handle_ru_datetimes(fq_form_schema) %>%
  ruODK::handle_ru_geopoints(fq_form_schema) %>%
  ruODK::handle_ru_attachments(fq_form_schema, local_dir = t)

fq_zip_strata <- fid_csv_veg %>%
  readr::read_csv(na = c("", "NA", "na")) %>%
  janitor::clean_names(.) %>%
  dplyr::mutate(id = parent_key) %>%
  # ruODK::handle_ru_datetimes(fq_form_schema) parent_key%>% # no dates
  # ruODK::handle_ru_geopoints(fq_form_schema) %>%  # no geopoints
  # ruODK::handle_ru_attachments(fq_form_schema, local_dir = t) %>% # no attachm.
  dplyr::left_join(fq_zip_data, by = c("parent_key" = "meta_instance_id"))

fq_zip_taxa <- fid_csv_tae %>%
  readr::read_csv(na = c("", "NA", "na")) %>%
  janitor::clean_names(.) %>%
  dplyr::mutate(id = parent_key) %>%
  # ruODK::handle_ru_datetimes(fq_form_schema) %>%
  # ruODK::handle_ru_geopoints(fq_form_schema) %>%
  # ruODK::handle_ru_attachments(fq_form_schema, local_dir = t) %>%
  dplyr::left_join(fq_zip_data, by = c("parent_key" = "meta_instance_id"))


fq_submission_list <- ruODK::submission_list()
fq_submissions <- ruODK::submission_get(fq_submission_list$instance_id)
fq_attachments <- ruODK::attachment_list(fq_submission_list$instance_id)


# Save to package data
usethis::use_data(fq_svc, overwrite = T)
usethis::use_data(fq_meta, overwrite = T)
usethis::use_data(fq_raw, overwrite = T)
usethis::use_data(fq_raw_strata, overwrite = T)
usethis::use_data(fq_raw_taxa, overwrite = T)
usethis::use_data(fq_data, overwrite = T)
usethis::use_data(fq_data_strata, overwrite = T)
usethis::use_data(fq_data_taxa, overwrite = T)

usethis::use_data(geo_fs, overwrite = T)
usethis::use_data(geo_gj_raw, overwrite = T)
usethis::use_data(geo_gj, overwrite = T)
usethis::use_data(geo_wkt_raw, overwrite = T)
usethis::use_data(geo_wkt, overwrite = T)

usethis::use_data(fq_project_list, overwrite = T)
usethis::use_data(fq_project_detail, overwrite = T)
usethis::use_data(fq_form_list, overwrite = T)
usethis::use_data(fq_form_xml, overwrite = T)
usethis::use_data(fq_form_schema, overwrite = T)
usethis::use_data(fq_form_detail, overwrite = T)

usethis::use_data(fq_zip_data, overwrite = T)
usethis::use_data(fq_zip_strata, overwrite = T)
usethis::use_data(fq_zip_taxa, overwrite = T)

usethis::use_data(fq_submission_list, overwrite = T)
usethis::use_data(fq_submissions, overwrite = T)
usethis::use_data(fq_attachments, overwrite = T)

# Update header of vignettes/odata-api.Rmd with:
# - media/1568786958640.jpg
fs::dir_ls(here::here("attachments/media"), glob = "*.jpg") %>%
  fs::file_copy(here::here("media"), overwrite = TRUE)
ymlthis::yml_resource_files(
  ymlthis::yml(),
  fs::dir_ls(fs::path("media"), glob = "*.jpg")
)

# -----------------------------------------------------------------------------#
# If attachments in vignettes change
#
# Vignettes are big
# the repo is small
# so what shall we do
# let's mogrify all
# fs::dir_ls(here::here("media"), glob="*.jpg") %>%
# fs::file_copy(here::here("vignettes/media/"), overwrite = TRUE)
# system("find vignettes/media -type f -exec mogrify -resize 200x150 {} \\;")

# Cleanup temp files
fs::dir_delete(here::here("media"))
fs::dir_delete(here::here("attachments"))
fs::dir_ls(here::here(), glob = "*.zip") %>% fs::file_delete()
