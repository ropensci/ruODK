library(testthat)
library(ruODK)
library(vcr)

if (Sys.getenv("ODKC_TEST_URL") == "") {
  ru_msg_info("Test server not configured, skipping tests.")
} else {
  test_check("ruODK")
}
