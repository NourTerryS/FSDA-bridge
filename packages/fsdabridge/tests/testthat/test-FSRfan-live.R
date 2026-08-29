test_that("FSRfan wrapper agrees with MATLAB/FSDA", {
  skip_if_not(
    identical(Sys.getenv("FSDA_LIVE"), "1"),
    "set FSDA_LIVE=1 to run the live MATLAB/FSDA test"
  )

  python = Sys.getenv("FSDA_DEV_VENV")
  if (!nzchar(python)) {
    python = "C:/Users/hp/FSDA-bridge/fsda-venv/Scripts/python.exe"
  }

  fsda_root = Sys.getenv("FSDA_ROOT")
  if (!nzchar(fsda_root)) {
    fsda_root = NULL
  }

  h = start_engine("FSRfan", python = python, fsda_root = fsda_root)
  on.exit(stop_engine(h), add = TRUE)

  find_repo_root = function() {
    current = normalizePath(getwd(), winslash = "/", mustWork = TRUE)

    repeat {
      candidate = file.path(
        current,
        "code",
        "FSRfan",
        "reference",
        "wool.txt"
      )

      if (file.exists(candidate)) {
        return(current)
      }

      parent = dirname(current)

      if (identical(parent, current)) {
        stop(
          "Could not locate repository root containing ",
          "code/FSRfan/reference/wool.txt"
        )
      }

      current = parent
    }
  }

  repo_root = find_repo_root()

  reference_dir = file.path(
    repo_root,
    "code",
    "FSRfan",
    "reference"
  )

  wool_path = file.path(reference_dir, "wool.txt")
  score_path = file.path(reference_dir, "FSRfan_Score_check.csv")
  la_path = file.path(reference_dir, "FSRfan_la_check.csv")

  expect_true(file.exists(wool_path))
  expect_true(file.exists(score_path))
  expect_true(file.exists(la_path))

  wool = as.matrix(
    read.table(
      wool_path,
      header = FALSE
    )
  )

  storage.mode(wool) = "double"

  y = wool[, ncol(wool)]
  X = wool[, seq_len(ncol(wool) - 1), drop = FALSE]

  expected_score = as.matrix(
    read.csv(
      score_path,
      header = FALSE
    )
  )

  expected_la = as.numeric(
    read.csv(
      la_path,
      header = FALSE
    )[[1]]
  )

  result = FSRfan(
    h,
    y,
    X,
    plots = 0,
    msg = FALSE
  )

  result_score = result$Score
  result_la = as.numeric(result$la)

  expect_true(is.matrix(result_score))
  expect_equal(dim(result_score), dim(expected_score))
  expect_equal(result_la, expected_la)

  expect_lte(
    max(abs(result_score - expected_score)),
    1e-9
  )
})