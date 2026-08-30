#' Forward Search Fan Plot Score Test (FSRfan)
#'
#' Thin wrapper around `fsda_call()` for the FSDA `FSRfan` routine.
#' Monitors score test statistics for transformation parameters during
#' the forward search.
#'
#' @param handle Engine handle from [start_engine()].
#' @param y Response vector. A row or column vector with n elements.
#' @param X Predictor matrix (n, p-1). The intercept must be included.
#' @param ... Name/value options passed straight through to `FSRfan`
#'   (e.g. `family`, `h`, `init`, `intercept`).
#' @return The `FSRfan` output converted to R (named list).
#' @examples
#' \dontrun{
#' h = start_engine("FSRfan")
#' out = FSRfan(h, y, X, family = "BoxCox")
#' stop_engine(h)
#' }
#' @export
FSRfan = function(handle, y, X, ...) {
  fsda_call(handle, "FSRfan", y, X, ...)
}