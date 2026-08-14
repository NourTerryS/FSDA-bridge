# TEST-REPORT — mahalFS (Multivariate distance)

**Scope:** Validation of the `mahalFS` FSDA routine (Mahalanobis distance computation) called through the shared `fsdabridge` engine (`engine.R` / `engine.py`), as part of Group 2's R package work for FSDA-bridge.

## Objective

Validate that `mahalFS(Y, MU, SIGMA)` — computing Mahalanobis distances for a set of observations from a given mean and covariance — produces results matching the project's committed gold reference when called through the shared engine, and probe the routine's behavior under invalid/edge-case inputs per the team's standardized test pattern.

## Acceptance criterion

A numeric result only counts as agreeing with a reference if the maximum absolute difference is <= 1e-9 — same as the project's own agreement gate (`check_engine.R`). Where no published reference exists for a check, results are reported as INFO rather than PASS/FAIL.

## Environment

- **R:** 4.6.1 ("Happy Hop"), platform aarch64-apple-darwin23
- **Python:** 3.12 (virtual environment `fsda_env`), packages: numpy, pandas, matlabengine 26.1.x
- **MATLAB:** R2026a, with FSDA Add-On installed
- **OS:** macOS (Apple Silicon)
- **R packages used:** reticulate

## How to reproduce
cd FSDA-bridge
source fsda_env/bin/activate
export FSDA_DEV_VENV=/absolute/path/to/FSDA-bridge/fsda_env/bin/python
Rscript code/test_mahalFS.R
## Findings

| ID | Severity | What happens | Fix recommendation |
|---|---|---|---|
| M5 | Doc gap | `mahalFS` accepts a singular (non-invertible) `SIGMA` without rejecting it. MATLAB itself only emits a warning (`Warning: Matrix is singular to working precision.`) and still returns a numeric result, rather than raising an error. The R layer currently passes this warning through silently — no R-level error or explicit warning is surfaced to the caller. | Consider adding a positive-definiteness check in the R wrapper (e.g. attempt `chol(SIGMA)` in a `tryCatch` and raise a clear R error if it fails) so callers get an explicit, actionable error instead of a numeric result computed against a degenerate covariance matrix. At minimum, document this behavior clearly so package users are aware a singular `SIGMA` will not be rejected. |

No High or Medium severity defects were found. `mahalFS` correctly rejects the two dimension-mismatch cases tested (M1, M2) with clear MATLAB-level errors that propagate cleanly through the R engine, and correctly propagates `NA` through to its output (M3) rather than silently ignoring it.

## Verified correct

- `mahalFS` reproduces the project's own gold reference values (5-point fixture) to a maximum absolute difference of `1.776357e-15` — six orders of magnitude below the required `1e-9` tolerance. **(M0 — PASS)**
- A `MU` vector with the wrong length (3 elements instead of 2, matching `Y`'s column count) is correctly rejected with a clear MATLAB dimension-mismatch error, raised from `mahalFS.m` line 64 (`bsxfun`). **(M1 — CLEAN-ERROR)**
- A non-square `SIGMA` (1x3 instead of 2x2) is correctly rejected with a clear MATLAB matrix-dimension error, raised from `mahalFS.m` line 65. **(M2 — CLEAN-ERROR)**
- `NA` values in `Y` propagate through to the output as non-finite values rather than being silently dropped or ignored. **(M3 — CLEAN-ERROR)**
- A single-observation input (`n = 1`) is handled without crashing and returns a valid distance. **(M4 — SILENT-OK, reviewed, no issue)**
- The routine is fully deterministic: two consecutive calls with identical inputs return bit-identical results (`max abs diff between two identical calls = 0.000e+00`). **(M6 — INFO)**
- The call path through the shared `engine.R` functions (`start_engine`, `fsda_call`, `stop_engine`) works correctly with no packaging-introduced discrepancy versus the raw engine.

## Full test log

| ID | Test | Reference | Status |
|---|---|---|---|
| M0 | mahalFS baseline vs. gold reference (5-point fixture) | `code/mahalFS/reference/mahalFS_r_check.csv` | PASS — max abs diff 1.776e-15 (tol 1e-9) |
| M1 | MU with wrong dimension (3 instead of 2) | — (edge case) | CLEAN-ERROR — `Non-singleton dimensions of the two input arrays must match each other` (mahalFS.m line 64) |
| M2 | Non-square SIGMA (1x3 instead of 2x2) | — (edge case) | CLEAN-ERROR — `Matrix dimensions must agree` (mahalFS.m line 65) |
| M3 | Y containing NA | — (edge case) | CLEAN-ERROR — NA propagated into output distances (expected) |
| M4 | Single-observation input (n = 1) | — (edge case) | SILENT-OK — returned 0.571428571428571, no error |
| M5 | Singular (non-invertible) SIGMA | — (edge case) | SILENT-OK — MATLAB warning only (`Matrix is singular to working precision`), result still returned; see Findings |
| M6 | Repeat calls return identical results (determinism) | — (self-comparison) | INFO — max abs diff between two identical calls = 0.000e+00 |

## Summary

7 checks were run against `mahalFS`. The baseline numeric result (M0) passed with a maximum absolute difference of 1.776357e-15, well within the required 1e-9 tolerance, confirming the shared engine and package wrapper introduce no computational discrepancy. Three edge-case checks (M1, M2, M3) confirmed clean, correct rejection of invalid dimensions and correct propagation of missing values. Two checks (M4, M5) returned results without error; of these, M4 (single observation) was reviewed and found to be correct behavior, while M5 (singular covariance matrix) was flagged as a documentation gap — the routine silently accepts a degenerate `SIGMA` with only a MATLAB-level warning rather than an explicit rejection, and this has been logged as a fix recommendation for the shared package's input validation layer. One determinism check (M6) confirmed fully repeatable output across identical calls. Total: 1 PASS, 3 CLEAN-ERROR, 2 SILENT-OK (1 reviewed as correct, 1 logged as a Doc-gap finding), 1 INFO, 0 High/Medium severity defects.
