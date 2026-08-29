#' Run FSDA tkmeans clustering (trimmed k-means)
#'
#' Computes trimmed k-means via FSDA's \code{tkmeans}: partitions the n-by-v
#' data matrix \code{data} into \code{k} clusters while trimming a fraction
#' \code{alpha} of units as potential outliers, using (unlike
#' \code{\link{fsda_tclust}}) unconstrained spherical/simple within-cluster
#' variability rather than restricted covariance matrices -- so, unlike
#' tclust, there is no \code{restrfactor} argument here.
#'
#' @param data Matrix of observations (n x v).
#' @param k Number of clusters.
#' @param alpha Trimming level (proportion of units trimmed as outliers).
#' @param ... Additional FSDA MATLAB name-value options (e.g. \code{plots},
#'   \code{Ysave}, \code{nsamp}).
#'
#' @return An object of class \code{"fsda_tkmeans"}.
#'
#' @examples
#' \dontrun{
#' result <- fsda_tkmeans(X, k = 3, alpha = 0.05)
#' print(result)
#' }
#' @export
fsda_tkmeans <- function(
  data,
  k,
  alpha,
  ...
) {
    eng <- start_engine()

    on.exit(
        stop_engine(eng),
        add = TRUE
    )

    args <- list(
        data,
        k,
        alpha
    )

    args <- c(
        args,
        list(...)
    )

    result <- do.call(
        fsda_call,
        c(
            list(
                handle = eng,
                name = "tkmeans"
            ),
            args
        )
    )

    result$call <- match.call()

    result$n <- nrow(data)
    result$p <- ncol(data)
    result$k <- k
    result$alpha <- alpha

    class(result) <- c(
        "fsda_tkmeans",
        class(result)
    )

    result
}
