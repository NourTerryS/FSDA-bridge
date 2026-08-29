test_that("mcd matches MATLAB", {
  skip_if_not(
    identical(Sys.getenv("FSDA_LIVE"), "1"),
    "set FSDA_LIVE=1 to run the live MATLAB/FSDA test"
  )

  fsda_root = Sys.getenv("FSDA_ROOT")
  if (!nzchar(fsda_root)) {
    fsda_root = NULL
  }

  h = start_engine("mcd", fsda_root = fsda_root)
  on.exit(stop_engine(h), add = TRUE)

  ref_dir = system.file("extdata", "mcd", package = "fsdabridge")
  y_path = file.path(ref_dir, "hawkins.csv")
  raw_loc_path = file.path(ref_dir, "RAW_loc.csv")
  raw_cov_path = file.path(ref_dir, "RAW_cov.csv")
  rew_loc_path = file.path(ref_dir, "REW_loc.csv")
  rew_cov_path = file.path(ref_dir, "REW_cov.csv")

  expect_true(nzchar(ref_dir))
  expect_true(file.exists(y_path))
  expect_true(file.exists(raw_loc_path))
  expect_true(file.exists(raw_cov_path))
  expect_true(file.exists(rew_loc_path))
  expect_true(file.exists(rew_cov_path))

  Y = as.matrix(read.csv(y_path, stringsAsFactors = FALSE))
  expected_raw_loc = as.numeric(as.matrix(read.csv(raw_loc_path, stringsAsFactors = FALSE)))
  expected_raw_cov = as.matrix(read.csv(raw_cov_path, stringsAsFactors = FALSE))
  expected_rew_loc = as.numeric(as.matrix(read.csv(rew_loc_path, stringsAsFactors = FALSE)))
  expected_rew_cov = as.matrix(read.csv(rew_cov_path, stringsAsFactors = FALSE))

  eval_m(h, "rng(0)", nargout = 0)
  out = mcd(h, Y, plots = 0, msg = 0)
  try(eval_m(h, "close all;", nargout = 0), silent = TRUE)

  expect_equal(length(out), 2)
  expect_equal(names(out), c("RAW", "REW"))

  RAW = out$RAW
  REW = out$REW

  expect_equal(as.character(RAW$class), "mcd")
  expect_equal(as.character(REW$class), "mcdr")

  raw_loc = as.numeric(RAW$loc)
  expect_equal(length(raw_loc), length(expected_raw_loc))
  expect_lte(max(abs(raw_loc - expected_raw_loc)), 1e-9)

  raw_cov = as.matrix(RAW$cov)
  expect_equal(dim(raw_cov), dim(expected_raw_cov))
  expect_lte(max(abs(raw_cov - expected_raw_cov)), 1e-9)

  rew_loc = as.numeric(REW$loc)
  expect_equal(length(rew_loc), length(expected_rew_loc))
  expect_lte(max(abs(rew_loc - expected_rew_loc)), 1e-9)

  rew_cov = as.matrix(REW$cov)
  expect_equal(dim(rew_cov), dim(expected_rew_cov))
  expect_lte(max(abs(rew_cov - expected_rew_cov)), 1e-9)
})
