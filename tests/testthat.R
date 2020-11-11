library(testthat)
library(ruODK)
library(vcr)

invisible(vcr::vcr_configure(
  filter_sensitive_data = list(
    "un" = get_test_un(),
    "pw" = get_test_pw()
  ),
  dir = "fixtures",
  match_requests_on = c('query', 'headers', 'uri', 'method'),
  record = "all"
))
vcr::check_cassette_names()

test_check("ruODK")
