test_that("FSRaddt wrapper is exported and has the expected interface", {
  expect_true(exists("FSRaddt", envir = asNamespace("fsdabridge"), inherits = FALSE))

  fn = get("FSRaddt", envir = asNamespace("fsdabridge"))

  expect_true(is.function(fn))
  expect_true(all(c("handle", "y", "X", "...") %in% names(formals(fn))))
})
