test_that("form_assignment_role_list shows role assignments", {
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
    "ruodk_farl_{format(Sys.time(), '%Y%m%d%H%M%S')}"
  ) |>
    as.character()
  form_create(xml = ru_test_form_xml(fid), publish = TRUE)

  withr::defer(
    httr::DELETE(
      paste0(get_test_url(), "/v1/projects/", get_test_pid(), "/forms/", fid),
      httr::authenticate(get_test_un(), get_test_pw())
    )
  )

  actor_id <- assignment_list(
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw()
  )$actor_id[[1]]

  form_assignment_grant(fid = fid, role_id = "manager", actor_id = actor_id)

  rl <- form_assignment_role_list(role_id = "manager")
  hit <- rl[rl$actor_id == actor_id & rl$xml_form_id == fid, ]
  testthat::expect_equal(nrow(hit), 1)

  form_assignment_revoke(fid = fid, role_id = "manager", actor_id = actor_id)
})

test_that("form_assignment_role_list is version gated", {
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

  testthat::expect_warning(
    form_assignment_role_list(role_id = 2, odkc_version = "0.6"),
    "supported from v0.7"
  )
})

test_that("form_assignment_role_list rejects a missing role", {
  testthat::expect_error(
    form_assignment_role_list(
      role_id = NA,
      url = "http://localhost",
      un = "user",
      pw = "password"
    ),
    "single Role ID"
  )
})

# usethis::use_r("form_assignment_role_list")  # nolint
