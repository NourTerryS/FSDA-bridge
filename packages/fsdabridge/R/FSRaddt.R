#' Forward Search added t statistics for candidate variables (FSRaddt)
#'
#' Thin wrapper around `fsda_call()` for the FSDA `FSRaddt` routine.
#' Monitors, along the forward search, the added-t test statistics for
#' variables not yet in the model, to assess whether they should be added.
#'
#' @param handle Engine handle from [start_engine()].
#' @param y Response vector. A row or column vector with n elements.
#' @param X Predictor matrix (n, p-1). The intercept must be included.
#' @param ... Name/value options passed straight through to `FSRaddt`
#'   (e.g. `nsamp`, `intercept`, `init`, `plots`, `msg`).
#' @return The `FSRaddt` output converted to R (named list), including
#'   `Tdel` (the added-t statistics trajectory, as a step-by-variable
#'   matrix).
#' @examples
#' \dontrun{
#' h = start_engine("FSRaddt")
#' out = FSRaddt(h, y, X, nsamp = 0, intercept = TRUE, plots = 0)
#' stop_engine(h)
#' }
#' @export
FSRaddt = function(handle, y, X, ...) {
  fsda_call(handle, "FSRaddt", y, X, ...)
}
