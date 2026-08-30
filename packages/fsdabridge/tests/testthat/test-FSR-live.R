test_that("FSR wrapper agrees with MATLAB/FSDA", {
  skip_if_not(
    identical(Sys.getenv("FSDA_LIVE"), "1"),
    "set FSDA_LIVE=1 to run the live MATLAB/FSDA test"
  )

  fsda_root = Sys.getenv("FSDA_ROOT")
  if (!nzchar(fsda_root)) {
    fsda_root = NULL
  }

  h = start_engine("FSR", fsda_root = fsda_root)
  on.exit(stop_engine(h), add = TRUE)

  ref_dir = system.file("extdata", "FSR", package = "fsdabridge")
  stars_path = file.path(ref_dir, "stars.csv")
  mdr_path = file.path(ref_dir, "FSR_mdr.csv")

  expect_true(nzchar(ref_dir))
  expect_true(file.exists(stars_path))
  expect_true(file.exists(mdr_path))

  stars = as.matrix(read.csv(stars_path))
  y = matrix(stars[, ncol(stars)], ncol = 1)
  X = matrix(stars[, seq_len(ncol(stars) - 1)], ncol = ncol(stars) - 1)

  expected_mdr = as.matrix(read.csv(mdr_path))

  out = FSR(h, y, X, nsamp = 0, intercept = TRUE, plots = 0, msg = 0)

  expect_equal(as.character(out$class), "FSR")

  mdr = as.matrix(out$mdr)
  tail_n = nrow(mdr)
  tail_g = nrow(expected_mdr)
  tail = mdr[(tail_n - 4):tail_n, ]
  expected_tail = expected_mdr[(tail_g - 4):tail_g, ]

  expect_lte(max(abs(tail - expected_tail)), 1e-9)
})
