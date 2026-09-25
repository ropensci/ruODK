test_that("form_assignment grant/revoke roundtrip works", {
  skip_if(
    Sys.getenv("ODKC_TEST_URL") == "",
    message = "Test server not configured"
  )

  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  fid <- glue::glue(
    "ruodk_fasg_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  # Any existing Actor will do; the Form is fresh, so nothing is assigned yet
  actor_id <- assignment_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )$actor_id[[1]]

  before <- form_assignment_actors(fid = fid, role_id = "manager")
  testthat::expect_equal(nrow(before), 0)

  gr <- form_assignment_grant(
    fid = fid,
    role_id = "manager",
    actor_id = actor_id
  )
  testthat::expect_true(gr$success)

  during <- form_assignment_actors(fid = fid, role_id = "manager")
  testthat::expect_true(actor_id %in% during$id)

  rv <- form_assignment_revoke(
    fid = fid,
    role_id = "manager",
    actor_id = actor_id
  )
  testthat::expect_true(rv$success)

  after <- form_assignment_actors(fid = fid, role_id = "manager")
  testthat::expect_equal(nrow(after), 0)
})

test_that("form_assignment functions reject missing IDs", {
  url <- "http://localhost"
  un <- "user"
  pw <- "password"
  testthat::expect_error(
    form_assignment_actors(
      fid = "f",
      role_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Role ID"
  )
  testthat::expect_error(
    form_assignment_grant(
      fid = "f",
      role_id = "manager",
      actor_id = NA,
      url = url,
      un = un,
      pw = pw
    ),
    "single Actor ID"
  )
  testthat::expect_error(
    form_assignment_revoke(
      fid = "f",
      role_id = NA,
      actor_id = 1,
      url = url,
      un = un,
      pw = pw
    ),
    "single Role ID"
  )
  testthat::expect_error(
    form_assignment_grant(
      fid = "",
      role_id = "manager",
      actor_id = 1,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "Missing ODK Central"
  )
})

# usethis::use_r("form_assignment_grant")  # nolint
