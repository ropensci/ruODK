#' Title: ruODK walkthough
#' Author_img_url: ../man/figures/ruODK2.png
#' Cols: 120
#' Typing_speed: 0.05
#' Empty_wait: 1
#' End_wait: 20

# <<
# Use your form's OData Service URL (Form > Submissions > Analyse data)
# Read vignette("setup") on setting username and password via .Renviron
# <<
suppressMessages(library(tidyverse))
library(ruODK)
ruODK::ru_setup(
  svc = Sys.getenv("ODKC_TEST_SVC"),
  un = ruODK::get_test_un(),
  pw = ruODK::get_test_pw()
)

# <<
# List available submission data tables
# <<
fq_svc <- ruODK::odata_service_get()
fq_svc

# <<
# Download main submissions and attachments
# <<
fq_data <- ruODK::odata_submission_get(
  table = fq_svc$name[1], wkt = TRUE, verbose = TRUE
)

# <<
# Download first nested subtable, join to main submissions
# <<
fq_data_strata <- ruODK::odata_submission_get(
  table = fq_svc$name[2], wkt = TRUE, verbose = TRUE
) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))

# <<
# Download second nested subtable, join to main submissions
# <<
fq_data_taxa <- ruODK::odata_submission_get(
  table = fq_svc$name[3], wkt = TRUE, verbose = TRUE
) %>%
  dplyr::left_join(fq_data, by = c("submissions_id" = "id"))

# <<
# View data
# <<
names(fq_data)
head(fq_data)
head(fq_data_strata)
head(fq_data_taxa)
