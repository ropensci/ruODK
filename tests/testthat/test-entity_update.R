test_that("entity_update works", {
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

  ed <- entity_detail(did = did, eid = en$uuid[1])

  e_label <- ed$current_version$label


  # Update the field "details".
  details_0 <- ed$current_version$data$details
  details_1 <- paste0(details_0, ". Updated on ", Sys.time())
  details_2 <- paste0(details_0, ". Updated on ", Sys.time())

  testthat::expect_equal(ed$current_version$data$details, details_0)

  # Update the Entity (implicitly forced update) - update 1
  eu <- entity_update(
    did = did,
    eid = en$uuid[1],
    label = e_label,
    data = list(details = details_1)
  )
  testthat::expect_equal(eu$current_version$data$details, details_1)

  # Interlude: entity_changes after update 1
  ec_1 <- entity_changes(did = did, eid = en$uuid[1])
  testthat::expect_gt(length(ec_1), 0)

  # Update the Entity (implicitly forced update) - update 2
  eu <- entity_update(
    did = did,
    eid = en$uuid[1],
    label = e_label,
    data = list(details = details_2)
  )
  testthat::expect_equal(eu$current_version$data$details, details_2)

  # Interlude: entity_changes after update 2
  ec_2 <- entity_changes(did = did, eid = en$uuid[1])
  testthat::expect_gt(length(ec_2), length(ec_1))

  testthat::expect_equal(
    ed$current_version$version,
    eu$current_version$baseVersion
  )

  # Test entity_versions without conflicts flag
  ev <- entity_versions(did = did, eid = en$uuid[1])

  ev_names <- c(
    "conflict",
    "resolved",
    "base_diff",
    "server_diff",
    "last_good_version",
    "current",
    "label",
    "creator_id",
    "user_agent",
    "data",
    "version",
    "base_version",
    "data_received",
    "conflicting_properties",
    "created_at",
    "branch_id",
    "trunk_version",
    "branch_base_version",
    "creator",
    "source",
    "relevant_to_conflict"
  )

  testthat::expect_equal(names(ev), ev_names)

  # With conflicts flag
  # Prove that the entity has no conflicts
  ed <- entity_detail(did = did, eid = en$uuid[1])
  testthat::expect_equal(ed$current_version$conflictingProperties, NULL)

  # Expect no records for entity without conflicts
  ev_conflict <- entity_versions(did = did, eid = en$uuid[1], conflict = TRUE)
  testthat::expect_equal(nrow(ev_conflict), 0)
})

test_that("entitylist_update warns if odkc_version too low", {
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

  ed <- entity_detail(did = did, eid = en$uuid[1])

  e_label <- ed$current_version$label

  # Update the field "details".
  old_details <- ed$current_version$data$details
  new_details <- paste0(old_details, ". Updated on ", Sys.time())

  e_data <- list(details = new_details)

  testthat::expect_error(entity_update())

  testthat::expect_warning(
    entity_update(
      did = did,
      eid = en$uuid[1],
      label = e_label,
      data = e_data,
      odkc_version = "1.5.3"
    )
  )

  testthat::expect_error(
    entity_update(
      did = did,
      eid = "",
      label = e_label,
      data = e_data
    )
  )

  testthat::expect_error(
    entity_update(
      did = "",
      eid = en$uuid[1],
      label = e_label,
      data = e_data
    )
  )
})

# usethis::use_r("entity_update")  # nolint
