test_that("prepend_uuid works", {
  stuff <- "sdfsdf"
  uuid_stuff <- glue::glue("uuid:{stuff}") %>% as.character(.)
  expect_equal(uuid_stuff, prepend_uuid(stuff))
})


test_that("prepend_uuid undoes strip_uuid", {
  stuff <- "sdfsdf"
  uuid_stuff <- prepend_uuid(stuff)
  uuid_stuff_stripped <- strip_uuid(uuid_stuff)
  expect_equal(stuff, uuid_stuff_stripped)
})
