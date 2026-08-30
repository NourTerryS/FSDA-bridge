#' Forward Search for linear regression (FSR)
#'
#' Thin wrapper around `fsda_call()` for the FSDA `FSR` routine. Runs the
#' forward search from a robust starting subset, monitoring the minimum
#' deletion residual as units are added, to detect outliers and departures
#' from the assumed linear model.
#'
#' @param handle Engine handle from [start_engine()].
#' @param y Response vector. A row or column vector with n elements.
#' @param X Predictor matrix (n, p-1). The intercept must be included.
#' @param ... Name/value options passed straight through to `FSR` (e.g.
#'   `nsamp`, `intercept`, `init`, `plots`, `msg`).
#' @return The `FSR` output converted to R (named list), including `mdr`
#'   (the minimum deletion residual trajectory, as a two-column step/value
#'   matrix).
#' @examples
#' \dontrun{
#' h = start_engine("FSR")
#' out = FSR(h, y, X, nsamp = 0, intercept = TRUE, plots = 0)
#' stop_engine(h)
#' }
#' @export
FSR = function(handle, y, X, ...) {
  fsda_call(handle, "FSR", y, X, ...)
}
