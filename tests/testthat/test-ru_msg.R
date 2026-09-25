test_that("ru_msg_* output silent if not verbose", {
  # Messages can be hidden
  expect_message(ru_msg_success("Test", verbose = TRUE), "Test")
  expect_silent(ru_msg_success("Test", verbose = FALSE))
  expect_message(ru_msg_noop("Test", verbose = TRUE), "Test")
  expect_silent(ru_msg_noop("Test", verbose = FALSE))
  expect_message(ru_msg_info("Test", verbose = TRUE), "Test")
  expect_silent(ru_msg_info("Test", verbose = FALSE))

  # Warnings can be hidden
  expect_warning(ru_msg_warn("Test", verbose = TRUE), "Test")
  expect_silent(ru_msg_warn("Test", verbose = FALSE))

  # Errors can't be hidden
  expect_error(ru_msg_abort("Test"))
})

test_that("ruODK.quiet silences messages but not warnings or errors", {
  withr::local_options(ruODK.quiet = TRUE)

  expect_silent(ru_msg_success("Test", verbose = TRUE))
  expect_silent(ru_msg_noop("Test", verbose = TRUE))
  expect_silent(ru_msg_info("Test", verbose = TRUE))

  # Warnings are never silenced by ruODK.quiet
  expect_warning(ru_msg_warn("Test", verbose = TRUE), "Test")

  # Errors are never silenced by ruODK.quiet
  expect_error(ru_msg_abort("Test"))
})
