test_that("LXS wrapper is exported and callable", {
  expect_true(exists("LXS"))
  expect_true(is.function(LXS))
})