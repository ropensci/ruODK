test_that("entity_create creates single entities", {
  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  el <- entitylist_list()

  # Entity List name (dataset ID, did)
  did <- el$name[1]

  # All Entities of Entity List
  en <- entity_list(did = did)
  # ed <- entity_detail(did=did, eid = en$uuid[1])

  time_before_created <- Sys.time()

  # Create a single entity
  lab <- glue::glue("Entity {nrow(en) + 1} created by ruODK package test on {Sys.time()}")
  ec <- entity_create(
    did = did,
    label = lab,
    notes = lab,
    data = list(
      "status" = "needs_followup",
      "details" = "ruODK package test",
      "geometry" = "-33.2 115.0 0.0 0.0"
    )
  )

  ec_names <- c(
    "uuid",
    "creator_id",
    "conflict",
    "created_at",
    "updated_at",
    "deleted_at",
    "current_version"
  )
  testthat::expect_equal(names(ec), ec_names)

  time_created <- lubridate::ymd_hms(ec$created_at, tz = "UTC")
  time_before_create <- lubridate::ymd_hms(
    time_before_created,
    tz = "Australia/Perth"
  )

  testthat::expect_gte(time_created, time_before_create)
})

test_that("entity_create creates multiple entities", {
  testthat::skip("TODO")

  # ru_setup(
  #   pid = get_test_pid(),
  #   url = get_test_url(),
  #   un = get_test_un(),
  #   pw = get_test_pw(),
  #   odkc_version = get_test_odkc_version()
  # )
  #
  # el <- entitylist_list()
  #
  # # Entity List name (dataset ID, did)
  # did <- el$name[1]
  #
  # # All Entities of Entity List
  # en <- entity_list(did = did)
  # # ed <- entity_detail(did=did, eid = en$uuid[1])
  #
  # time_before_created <- Sys.time()
  #
  # # Create a single entity
  # lab = glue::glue(
  #   "Entity {nrow(en) + 1} created by ruODK package test on {Sys.time()}"
  # )
  # ec <- entity_create(
  #   did = did,
  #   label = lab,
  #   notes = lab,
  #   data = list(
  #     "status" = "needs_followup",
  #     "details" = "ruODK package test",
  #     "geometry"="-33.2 115.0 0.0 0.0"
  #   )
  # )
  #
  # testthat::expect_equal(names(ec), ec_names)
  #
  # time_created =  lubridate::ymd_hms(ec$created_at, tz = "UTC")
  # time_before_create = lubridate::ymd_hms(time_before_created, tz = "Australia/Perth")
  #
  # testthat::expect_gte(time_created, time_before_create)
})

test_that("entity_create input gatechecks", {
  ru_setup(
    pid = get_test_pid(),
    url = get_test_url(),
    un = get_test_un(),
    pw = get_test_pw(),
    odkc_version = get_test_odkc_version()
  )

  el <- entitylist_list()

  # Entity List name (dataset ID, did)
  did <- el$name[1]

  # All Entities of Entity List
  en <- entity_list(did = did)
  # ed <- entity_detail(did=did, eid = en$uuid[1])

  time_before_created <- Sys.time()

  # Create a single entity
  lab <- glue::glue(
    "Entity {nrow(en) + 1} created by ruODK package test on {Sys.time()}"
  )

  # ODKC version not supported
  testthat::expect_warning(entity_create(
    did = did,
    label = lab,
    data = list(
      "status" = "needs_followup",
      "details" = "ruODK package test",
      "geometry" = "-33.2 115.0 0.0 0.0"
    ),
    odkc_version = "1.5.3"
  ))

  # Missing dataset ID
  testthat::expect_error(entity_create())

  # Empty label, malformed data missing "entities"
  testthat::expect_error(entity_create(did = did, data = list()))
})
