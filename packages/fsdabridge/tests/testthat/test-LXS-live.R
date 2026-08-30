test_that("LXS wrapper agrees with MATLAB/FSDA", {
  skip_if_not(
    identical(Sys.getenv("FSDA_LIVE"), "1"),
    "set FSDA_LIVE=1 to run the live MATLAB/FSDA test"
  )

  fsda_root = Sys.getenv("FSDA_ROOT")
  if (!nzchar(fsda_root)) {
    fsda_root = NULL
  }

  h = start_engine("LXS", fsda_root = fsda_root)
  on.exit(stop_engine(h), add = TRUE)

  ref_dir = system.file("extdata", "LXS", package = "fsdabridge")
  wool_path = file.path(ref_dir, "wool.csv")
  beta_path = file.path(ref_dir, "LXS_beta.csv")

  expect_true(nzchar(ref_dir))
  expect_true(file.exists(wool_path))
  expect_true(file.exists(beta_path))

  wool = as.matrix(read.csv(wool_path))
  y = matrix(wool[, ncol(wool)], ncol = 1)
  X = wool[, seq_len(ncol(wool) - 1), drop = FALSE]

  expected_beta = as.numeric(as.matrix(read.csv(beta_path)))

  out = LXS(h, y, X, intercept = TRUE, plots = 0)

  expect_equal(as.character(out$class), "LMS")

  beta = as.numeric(out$beta)
  expect_equal(length(beta), length(expected_beta))
  expect_lte(max(abs(beta - expected_beta)), 1e-9)
})
