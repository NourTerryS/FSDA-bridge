#' Minimum Covariance Determinant
#'
#' @param handle Engine handle from [start_engine()].
#' @param Y Data matrix (n, p).
#' @param ... Optional arguments for `mcd`.
#' @param nargout Number of outputs (default 2).
#' @return A list with `RAW` and `REW` when `nargout = 2`.
#' @examples
#' \dontrun{
#' h = start_engine("mcd")
#' out = mcd(h, Y, plots = 0, msg = 0)
#' stop_engine(h)
#' }
#' @export
mcd = function(handle, Y, ..., nargout = 2) {
  out = fsda_call(handle, "mcd", Y, nargout = nargout, ...)
  if (nargout == 2) {
    names(out) = c("RAW", "REW")
  }
  out
}
