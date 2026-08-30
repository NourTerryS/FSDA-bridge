test_that("FSR wrapper is exported and has the expected interface", {
  expect_true(exists("FSR", envir = asNamespace("fsdabridge"), inherits = FALSE))

  fn = get("FSR", envir = asNamespace("fsdabridge"))

  expect_true(is.function(fn))
  expect_true(all(c("handle", "y", "X", "...") %in% names(formals(fn))))
})
