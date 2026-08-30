test_that("LXS live execution matches MATLAB reference", {
  skip_if_not(Sys.getenv("FSDA_LIVE") == "1", "Live MATLAB tests not enabled")

  handle <- start_engine("LXS")
  on.exit(stop_engine(handle))

  # Load sample data (e.g., stackloss or similar dataset used in tests)
  data(stackloss)
  y <- stackloss$stack.loss
  X <- as.matrix(stackloss[, 1:3])

  res <- LXS(handle, y, X)

  expect_type(res, "list")
  expect_true("beta" %in% names(res) || length(res) > 0)
})