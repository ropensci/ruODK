test_that("strip_uuid works", {
  expect_equal(
    "c0f9ce58-4388-4e7b-98d7-feac459d2e12",
    ruODK::strip_uuid("uuid:c0f9ce58-4388-4e7b-98d7-feac459d2e12")
  )
})

test_that("strip_uuid does its job even with weird clients", {
  expect_equal(
    "c0f9ce58-4388-4e7b-98d7-feac459d2e12",
    ruODK::strip_uuid("uuid:uuid:uuid:c0f9ce58-4388-4e7b-uuid:98d7-feac459d2e12uuid:uuid:")
  )
})
