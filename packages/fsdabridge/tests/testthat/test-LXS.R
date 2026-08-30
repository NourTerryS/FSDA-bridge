test_that("LXS formals are correct", {
  expect_true(is.function(LXS))
  formals_LXS <- formals(LXS)
  expect_true("handle" %in% names(formals_LXS))
  expect_true("y" %in% names(formals_LXS))
  expect_true("X" %in% names(formals_LXS))
})