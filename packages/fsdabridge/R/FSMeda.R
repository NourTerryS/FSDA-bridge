#' Forward Search monitoring for Multivariate data
#'
#' @param handle Engine handle from [start_engine()].
#' @param Y Data matrix (n, p).
#' @param bsb Initial subset, or `0` for a random subset.
#' @param ... Optional arguments for `FSMeda`.
#' @return A list with `MAL` and `mmd`.
#' @examples
#' \dontrun{
#' h = start_engine("FSMeda")
#' out = FSMeda(h, Y, bsb, init = 30, plots = 0, msg = 0)
#' stop_engine(h)
#' }
#' @export
FSMeda = function(handle, Y, bsb = 0, ...) {
  fsda_call(handle, "FSMeda", Y, bsb, ...)
}
