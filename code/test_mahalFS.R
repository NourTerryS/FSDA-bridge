# test_mahalFS.R
#
# Covers: mahalFS (Multivariate distance category), via the fsdabridge
# package's mahalFS() wrapper (R/mahalFS.R), which forwards to fsda_call().
# No engine/FSDA code is modified by this script.
# Acceptance tolerance: max absolute difference <= 1e-9 vs. reference.

library(fsdabridge)

# --- Locate repo root (for reading the gold reference CSV) ----------------
.repo_root = local({
  here = normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  candidates = c(here, file.path(here, ".."), file.path(here, "..", ".."))
  for (c in candidates) {
    if (dir.exists(file.path(c, "code", "mahalFS", "reference"))) {
      return(normalizePath(c, winslash = "/", mustWork = TRUE))
    }
  }
  stop("Cannot locate repo root (looking for code/mahalFS/reference)")
})

# --- Shared helper functions (copied verbatim, per team standard) --------
results = list()
record = function(id, test, status, detail = "") {
  results[[length(results) + 1]] <<- list(id = id, test = test, status = status, detail = detail)
  cat(sprintf("  [%s] %s — %s\n", status, id, detail))
}
one_line = function(msg, width = 200) {
  msg = gsub("[[:space:]]+", " ", msg)
  if (nchar(msg) > width) msg = paste0(substr(msg, 1, width), "...")
  msg
}
finite_ids = function(x) { v = suppressWarnings(as.numeric(x)); v[is.finite(v)] }
attempt = function(expr) {
  tryCatch(list(ok = TRUE, out = expr), error = function(e) list(ok = FALSE, msg = conditionMessage(e)))
}

# --- One MATLAB session for the whole script ------------------------------
cat("Starting FSDA engine...\n")
h = start_engine("mahalFS")
if (is.null(h)) stop("Engine failed to start")
cat("Engine started.\n\n")

TOL = 1e-9

# ===========================================================================
# Section 1 — Baseline agreement against the project's reference
# ===========================================================================
cat("== Section 1: baseline agreement ==\n")

Y     = matrix(c(1, 2, 2, 0, 3, 5, 0, -1, 4, 4), nrow = 5, byrow = TRUE)
MU    = c(2.0, 2.0)
SIGMA = matrix(c(2, 0.5, 0.5, 1), 2, 2)

ref_path = file.path(.repo_root, "code", "mahalFS", "reference", "mahalFS_r_check.csv")
gold = read.csv(ref_path)[, "d_fsda"]

res = attempt(as.numeric(mahalFS(h, Y, MU, SIGMA)))
if (res$ok) {
  diff = max(abs(res$out - gold))
  status = if (diff <= TOL) "PASS" else "FINDING"
  record("M0", "mahalFS baseline vs. gold reference (5-point fixture)", status,
         sprintf("max abs diff = %.3e (tol %.0e)", diff, TOL))
} else {
  record("M0", "mahalFS baseline vs. gold reference (5-point fixture)", "FINDING",
         one_line(paste("call failed:", res$msg)))
}

# ===========================================================================
# Section 2 — Deliberate break attempts
# ===========================================================================
cat("\n== Section 2: deliberate break attempts ==\n")

# M1 — mismatched dimensions between Y and MU
res = attempt(mahalFS(h, Y, c(2.0, 2.0, 2.0), SIGMA))
status = if (!res$ok) "CLEAN-ERROR" else "SILENT-OK"
record("M1", "MU with wrong dimension (3 instead of 2)", status,
       if (!res$ok) one_line(res$msg) else "ran without error — no dimension check surfaced")

# M2 — non-square SIGMA
bad_sigma = matrix(c(2, 0.5, 0.5), nrow = 1)
res = attempt(mahalFS(h, Y, MU, bad_sigma))
status = if (!res$ok) "CLEAN-ERROR" else "SILENT-OK"
record("M2", "Non-square SIGMA (1x3 instead of 2x2)", status,
       if (!res$ok) one_line(res$msg) else "ran without error — no shape check surfaced")

# M3 — NA / missing values in Y
Y_na = Y
Y_na[1, 1] = NA
res = attempt(mahalFS(h, Y_na, MU, SIGMA))
if (!res$ok) {
  record("M3", "Y containing NA", "CLEAN-ERROR", one_line(res$msg))
} else {
  d = suppressWarnings(as.numeric(res$out))
  if (any(!is.finite(d))) {
    record("M3", "Y containing NA", "CLEAN-ERROR", "NA propagated into output distances (expected)")
  } else {
    record("M3", "Y containing NA", "FINDING", "NA silently dropped/ignored — output looks fully finite")
  }
}

# M4 — single-row Y (n = 1)
res = attempt(mahalFS(h, Y[1, , drop = FALSE], MU, SIGMA))
status = if (res$ok) "SILENT-OK" else "CLEAN-ERROR"
record("M4", "Single-observation input (n = 1)", status,
       if (res$ok) one_line(paste("returned:", paste(res$out, collapse = ", "))) else one_line(res$msg))

# M5 — SIGMA not positive-definite (singular)
bad_sigma2 = matrix(c(1, 1, 1, 1), 2, 2)
res = attempt(mahalFS(h, Y, MU, bad_sigma2))
status = if (!res$ok) "CLEAN-ERROR" else "SILENT-OK"
record("M5", "Singular (non-invertible) SIGMA", status,
       if (!res$ok) one_line(res$msg) else "ran without error — no positive-definiteness check surfaced")

# ===========================================================================
# Section 3 — Routine-specific check: determinism / repeatability
# ===========================================================================
cat("\n== Section 3: determinism ==\n")

res1 = attempt(as.numeric(mahalFS(h, Y, MU, SIGMA)))
res2 = attempt(as.numeric(mahalFS(h, Y, MU, SIGMA)))
if (res1$ok && res2$ok) {
  diff = max(abs(res1$out - res2$out))
  record("M6", "Repeat calls return identical results (determinism)", "INFO",
         sprintf("max abs diff between two identical calls = %.3e", diff))
} else {
  record("M6", "Repeat calls return identical results (determinism)", "FINDING", "one or both repeat calls failed")
}

# --- Wrap up ---------------------------------------------------------------
stop_engine(h)
cat("\nEngine stopped.\n\n")

cat("== Results table ==\n")
df = do.call(rbind, lapply(results, function(r) data.frame(
  ID = r$id, Test = r$test, Status = r$status, Detail = r$detail, stringsAsFactors = FALSE
)))
print(df, row.names = FALSE)

n_pass    = sum(sapply(results, function(r) r$status == "PASS"))
n_clean   = sum(sapply(results, function(r) r$status == "CLEAN-ERROR"))
n_silent  = sum(sapply(results, function(r) r$status == "SILENT-OK"))
n_finding = sum(sapply(results, function(r) r$status == "FINDING"))
n_info    = sum(sapply(results, function(r) r$status == "INFO"))

cat(sprintf(
  "\nSummary: %d checks — %d PASS, %d CLEAN-ERROR, %d SILENT-OK, %d FINDING, %d INFO\n",
  length(results), n_pass, n_clean, n_silent, n_finding, n_info
))
