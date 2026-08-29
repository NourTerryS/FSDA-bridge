test_that("FSMeda matches MATLAB", {
  skip_if_not(
    identical(Sys.getenv("FSDA_LIVE"), "1"),
    "set FSDA_LIVE=1 to run the live MATLAB/FSDA test"
  )

  fsda_root = Sys.getenv("FSDA_ROOT")
  if (!nzchar(fsda_root)) {
    fsda_root = NULL
  }

  h = start_engine("FSMeda", fsda_root = fsda_root)
  on.exit(stop_engine(h), add = TRUE)

  ref_dir = system.file("extdata", "FSMeda", package = "fsdabridge")
  y_path = file.path(ref_dir, "hawkins.csv")
  mal_path = file.path(ref_dir, "MAL.csv")
  mmd_path = file.path(ref_dir, "mmd.csv")

  expect_true(nzchar(ref_dir))
  expect_true(file.exists(y_path))
  expect_true(file.exists(mal_path))
  expect_true(file.exists(mmd_path))

  Y = as.matrix(read.csv(y_path, stringsAsFactors = FALSE))
  bsb = matrix(1:20, ncol = 1)
  expected_mal = as.matrix(read.csv(mal_path, stringsAsFactors = FALSE))
  expected_mmd = as.matrix(read.csv(mmd_path, stringsAsFactors = FALSE))

  out = FSMeda(h, Y, bsb, init = 30, msg = 0, plots = 0)

  expect_equal(as.character(out$class), "FSMeda")

  mal = as.matrix(out$MAL)
  expect_equal(dim(mal), dim(expected_mal))
  expect_lte(max(abs(mal - expected_mal)), 1e-9)

  mmd = as.matrix(out$mmd)
  expect_equal(dim(mmd), dim(expected_mmd))
  expect_lte(max(abs(mmd - expected_mmd)), 1e-9)
})
