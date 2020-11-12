library(testthat)
library(ruODK)
library(vcr)

invisible(vcr::vcr_configure(
  filter_sensitive_data = list(
    "<<un>>" = get_test_un(),
    "<<pw>>" = get_test_pw()
  ),
  dir = "fixtures",
  write_disk_path = "files",
  record = "once",
  log = FALSE
))
vcr::check_cassette_names()

test_check("ruODK")
