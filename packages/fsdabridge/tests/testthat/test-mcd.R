test_that("mcd is exported", {
  expect_true(exists("mcd", envir = asNamespace("fsdabridge"), inherits = FALSE))

  fn = get("mcd", envir = asNamespace("fsdabridge"))

  expect_true(is.function(fn))
  expect_true(all(c("handle", "Y", "...", "nargout") %in% names(formals(fn))))
})
