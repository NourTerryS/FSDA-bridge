#' Univariate and Bivariate Outlier Detection (unibiv)
#'
#' Thin wrapper around `fsda_call()` for the FSDA `unibiv` routine —
#' detects univariate and bivariate outliers in a multivariate dataset
#' `Y` by counting how often each observation falls outside robust
#' bivariate ellipses, together with its Mahalanobis distance.
#'
#' @param handle Engine handle from [start_engine()].
#' @param Y Data matrix (n, v) of observations.
#' @param ... Additional name/value options passed straight through to
#'   unibiv.
#' @return A matrix `fre` with one row per observation, describing how
#'   many times each unit fell outside the robust bivariate ellipses and
#'   its Mahalanobis distance.
#' @examples
#' \dontrun{
#' h = start_engine("unibiv")
#' fre = unibiv(h, Y)
#' stop_engine(h)
#' }
#' @export
unibiv = function(handle, Y, ...) {
  fsda_call(handle, "unibiv", Y, ...)
}
