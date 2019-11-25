# 1. Set ODK Central credentials
# 1.1. Open .Renviron
# usethis::edit_r_environ()

# 1.2. Add credentials
# ODKC_UN="me@email.com"
# ODKC_PW="..."

# 1.3. restart R session

# 2. Setup ruODK with OData Service URL (Form > Submissions > Analyze data)
library(ruODK)
ruODK::ru_setup(svc = "https://sandbox.central.opendatakit.org/v1/projects/14/forms/build_Flora-Quadrat-0-4_1564384341.svc")

# Settings for timezone and file attachment download location
tz <- "Australia/Perth"
loc <- fs::path("attachments", "media")

# 3. List available submission data tables
fq_svc <- ruODK::odata_service_get()
fq_svc

# 4. Hammertime
fq_data <- ruODK::odata_submission_get(
  table = fq_svc$name[1], verbose = TRUE, tz = tz, local_dir = loc
) %>%
  dplyr::rename(
    longitude = x13,
    latitude = x14,
    altitude = x15
  )

skimr::skim(fq_data)
dplyr::glimpse(fq_data)
