test_that("FSRaddt wrapper agrees with MATLAB/FSDA", {
  skip_if_not(
    identical(Sys.getenv("FSDA_LIVE"), "1"),
    "set FSDA_LIVE=1 to run the live MATLAB/FSDA test"
  )

  fsda_root = Sys.getenv("FSDA_ROOT")
  if (!nzchar(fsda_root)) {
    fsda_root = NULL
  }

  h = start_engine("FSRaddt", fsda_root = fsda_root)
  on.exit(stop_engine(h), add = TRUE)

  ref_dir = system.file("extdata", "FSRaddt", package = "fsdabridge")
  wool_path = file.path(ref_dir, "wool.csv")
  tdel_path = file.path(ref_dir, "FSRaddt_Tdel.csv")

  expect_true(nzchar(ref_dir))
  expect_true(file.exists(wool_path))
  expect_true(file.exists(tdel_path))

  wool = as.matrix(read.csv(wool_path))
  y = matrix(wool[, ncol(wool)], ncol = 1)
  X = wool[, seq_len(ncol(wool) - 1), drop = FALSE]

  expected_tdel = as.matrix(read.csv(tdel_path))

  out = FSRaddt(h, y, X, nsamp = 0, intercept = TRUE, plots = 0, msg = 0)

  td = as.matrix(out$Tdel)
  tail_n = nrow(td)
  tail_g = nrow(expected_tdel)
  tail = td[(tail_n - 2):tail_n, ]
  expected_tail = expected_tdel[(tail_g - 2):tail_g, ]

  expect_lte(max(abs(tail - expected_tail)), 1e-9)
})
