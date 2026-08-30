#' MM estimator of regression coefficients (MMreg)
#'
#' Thin wrapper around `fsda_call()` for the FSDA `MMreg` routine. Computes
#' MM estimates of regression coefficients, starting from an S estimate of
#' the residual scale, for a highly robust and asymptotically efficient
#' fit.
#'
#' @param handle Engine handle from [start_engine()].
#' @param y Response vector. A row or column vector with n elements.
#' @param X Predictor matrix (n, p-1). The intercept must be included.
#' @param ... Name/value options passed straight through to `MMreg` (e.g.
#'   `Sbeta`, `auxscale`, `conflev`, `plots`, `msg`).
#' @return The `MMreg` output converted to R (named list), including `beta`
#'   (the MM regression coefficient estimates).
#' @examples
#' \dontrun{
#' h = start_engine("MMreg")
#' out = MMreg(h, y, X, plots = 0)
#' stop_engine(h)
#' }
#' @export
MMreg = function(handle, y, X, ...) {
  fsda_call(handle, "MMreg", y, X, ...)
}
