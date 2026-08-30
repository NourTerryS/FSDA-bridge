test_that("FSMeda is exported", {
  expect_true(exists("FSMeda", envir = asNamespace("fsdabridge"), inherits = FALSE))

  fn = get("FSMeda", envir = asNamespace("fsdabridge"))

  expect_true(is.function(fn))
  expect_true(all(c("handle", "Y", "bsb", "...") %in% names(formals(fn))))
})
