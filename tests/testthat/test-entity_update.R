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
  old_details <- ed$current_version$data$details
  new_details <- paste0(old_details, ". Updated on ", Sys.time())

  e_data <- list(details = new_details)

  # Update the Entity (implicitly forced update)
  eu <- entity_update(
    did = did,
    eid = en$uuid[1],
    label = e_label,
    data = e_data
  )

  testthat::expect_equal(ed$current_version$data$details, old_details)

  testthat::expect_equal(eu$current_version$data$details, new_details)

  testthat::expect_equal(ed$current_version$version,
                         eu$current_version$baseVersion)
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
