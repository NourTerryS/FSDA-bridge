#' @title LXS Wrapper
#' @description MATLAB LXS function wrapper.
#' @param handle MATLAB engine handle.
#' @param Y Input data.
#' @param ... Additional arguments.
#' @return Returns the MATLAB output.
#' @export
LXS <- function(handle, Y, ...) {
  fsda_call(handle, "LXS", Y, ...)
}
