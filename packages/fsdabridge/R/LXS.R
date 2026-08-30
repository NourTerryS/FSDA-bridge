#' LXS
#'
#' @description Computes least trimmed squares (LXS) estimators.
#' @param handle MATLAB engine handle.
#' @param y Response variable vector.
#' @param X Predictor matrix.
#' @param ... Additional arguments passed to MATLAB.
#' @return MATLAB engine output for LXS.
#' @export
LXS <- function(handle, y, X, ...) {
  fsda_call(handle, "LXS", y, X, ...)
}