library(testthat)
library(ruODK)
library(vcr)

invisible(vcr::vcr_configure(
  filter_sensitive_data = list(
    "<<un>>" = get_test_un(),
    "<<pw>>" = get_test_pw(),
    "<<pp>>" = get_test_pp()
  ),
  dir = "fixtures",
  write_disk_path = "files",
  record = "new_episodes",
  log = FALSE
))
vcr::check_cassette_names()

test_check("ruODK")
