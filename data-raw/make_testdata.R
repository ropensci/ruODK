# ODK Central credentials
if (file.exists("~/.Rprofile")) source("~/.Rprofile")

# ODK Central server/project/form
odk_central <- "https://sandbox.central.opendatakit.org/"
project_id <- 14
form_id <- "build_Flora-Quadrat-0-2_1558575936"

base_url <- glue::glue("{odk_central}v1/projects/{project_id}/forms/")
data_url <- glue::glue("{base_url}{form_id}.svc")

fq_meta <- get_metadata(data_url)
fq_raw <- get_submissions(data_url)

usethis::use_data(fq_meta, overwrite = T)
usethis::use_data(fq_raw, overwrite = T)
