# -----------------------------------------------------------------------------#
# ODK Central example data
#
library(magrittr)
ruODK::ru_setup(
  svc = Sys.getenv("ODKC_TEST_SVC"),
  un = Sys.getenv("ODKC_TEST_UN"),
  pw = Sys.getenv("ODKC_TEST_PW")
)

# Used in vignette odata-api
fq_svc <- ruODK::odata_service_get()
fq_meta <- ruODK::odata_metadata_get()
fq_fs <- ruODK::form_schema()
fq_raw <- ruODK::odata_submission_get(table = fq_svc$name[1], parse = FALSE)
fq_raw_strata <- ruODK::odata_submission_get(table = fq_svc$name[2], parse = FALSE)
fq_raw_taxa <- ruODK::odata_submission_get(table = fq_svc$name[3], parse = FALSE)
fq_data <- ruODK::odata_submission_get(table = fq_svc$name[1], parse = TRUE, wkt = TRUE)
fq_data_strata <- ruODK::odata_submission_get(
  table = fq_svc$name[2], parse = TRUE, wkt = TRUE, verbose = TRUE
) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))
fq_data_taxa <- ruODK::odata_submission_get(
  table = fq_svc$name[3], parse = TRUE, wkt = TRUE, verbose = TRUE
) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))

# Used in vignette rest-api
fq_project_list <- ruODK::project_list()
fq_project_detail <- ruODK::project_detail()
fq_form_list <- ruODK::form_list()
fq_form_xml <- ruODK::form_xml(parse = FALSE)
fq_form_schema_raw <- ruODK::form_schema(parse = FALSE)
fq_form_schema <- ruODK::form_schema(parse = TRUE)
fq_form_detail <- ruODK::form_detail()

t <- fs::dir_create("attachments")

fid <- ruODK::get_test_fid()
fid_csv <- fs::path(t, glue::glue("{fid}.csv"))
fid_csv_tae <- fs::path(t, glue::glue("{fid}-taxon_encounter.csv"))
fid_csv_veg <- fs::path(t, glue::glue("{fid}-vegetation_stratum.csv"))

se <- ruODK::submission_export(local_dir = t, overwrite = FALSE, verbose = TRUE)
f <- unzip(se, exdir = t)
fq_zip_data <- fid_csv %>%
  readr::read_csv(na = c("", "NA", "na")) %>% # form uses "na" for NA
  janitor::clean_names(.) %>%
  attachment_link(.) %>%
  ru_datetime(tz = "Australia/Perth") # an example timezone
fq_zip_strata <- fid_csv_veg %>%
  readr::read_csv(na = c("", "NA", "na")) %>%
  janitor::clean_names(.) %>%
  attachment_link(.) %>%
  ru_datetime(tz = "Australia/Perth") %>%
  dplyr::left_join(fq_zip_data, by = c("parent_key" = "meta_instance_id"))
fq_zip_taxa <- fid_csv_tae %>%
  readr::read_csv(na = c("", "NA", "na")) %>%
  janitor::clean_names(.) %>%
  attachment_link(.) %>%
  ru_datetime(tz = "Australia/Perth") %>%
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

usethis::use_data(fq_project_list, overwrite = T)
usethis::use_data(fq_project_detail, overwrite = T)
usethis::use_data(fq_form_list, overwrite = T)
usethis::use_data(fq_form_xml, overwrite = T)
usethis::use_data(fq_form_schema_raw, overwrite = T)
usethis::use_data(fq_form_schema, overwrite = T)
usethis::use_data(fq_form_detail, overwrite = T)

usethis::use_data(fq_zip_data, overwrite = T)
usethis::use_data(fq_zip_strata, overwrite = T)
usethis::use_data(fq_zip_taxa, overwrite = T)

usethis::use_data(fq_submission_list, overwrite = T)
usethis::use_data(fq_submissions, overwrite = T)
usethis::use_data(fq_attachments, overwrite = T)
