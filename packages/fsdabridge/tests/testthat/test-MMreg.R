test_that("MMreg wrapper is exported and has the expected interface", {
  expect_true(exists("MMreg", envir = asNamespace("fsdabridge"), inherits = FALSE))

  fn = get("MMreg", envir = asNamespace("fsdabridge"))

  expect_true(is.function(fn))
  expect_true(all(c("handle", "y", "X", "...") %in% names(formals(fn))))
})
