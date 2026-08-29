library(testthat)
library(fsdabridge)

# ---------------------------------------------------------------------------
# Helper: find the permutation of R's cluster labels that best aligns
# result$muopt with matlab_mu (tkmeans, like tclust, has no canonical
# cluster ordering, so labels can differ between implementations even when
# the underlying partition is identical).
# ---------------------------------------------------------------------------
match_labels <- function(mu_r, mu_matlab) {
    k <- nrow(mu_r)

    perm_matrix <- t(expand.grid(rep(list(seq_len(k)), k)))
    valid <- apply(perm_matrix, 2, function(p) length(unique(p)) == k)
    perm_matrix <- perm_matrix[, valid, drop = FALSE]

    best_perm <- NULL
    best_cost <- Inf

    for (j in seq_len(ncol(perm_matrix))) {
        p <- perm_matrix[, j]
        cost <- sum((mu_r[p, , drop = FALSE] - mu_matlab)^2)
        if (cost < best_cost) {
            best_cost <- cost
            best_perm <- p
        }
    }

    best_perm
}

test_that("TKMEANS matches MATLAB benchmark", {
    skip_if_not(
        identical(Sys.getenv("FSDA_LIVE"), "1"),
        "set FSDA_LIVE=1 to run the live MATLAB/FSDA test"
    )

    # -------------------------------------------------------------------
    # Load data (same dataset used for the tclust benchmark)
    # -------------------------------------------------------------------
    data_path <- system.file(
        "extdata",
        "geyser2.txt",
        package = "fsdabridge"
    )

    Y <- as.matrix(
        read.table(
            data_path,
            header = FALSE
        )
    )

    storage.mode(Y) <- "double"

    # -------------------------------------------------------------------
    # Run R/FSDA-bridge tkmeans
    # -------------------------------------------------------------------
    result <- fsda_tkmeans(
        Y,
        k = 3,
        alpha = 0.1
    )

    # -------------------------------------------------------------------
    # Load MATLAB benchmark outputs
    # (generated via generate_tkmeans_benchmark.m, copied into
    #  inst/extdata/tkmeans/)
    # -------------------------------------------------------------------
    matlab_mu <- as.matrix(
        read.csv(
            system.file("extdata", "tkmeans", "mu_MATLAB_tkmeans.csv", package = "fsdabridge"),
            header = FALSE
        )
    )
    storage.mode(matlab_mu) <- "double"

    matlab_obj <- as.numeric(
        read.csv(
            system.file("extdata", "tkmeans", "obj_MATLAB_tkmeans.csv", package = "fsdabridge"),
            header = FALSE
        )[[1]]
    )

    # siz is a (k+1) x 3 matrix in MATLAB: label | size | percentage
    matlab_siz <- as.matrix(
        read.csv(
            system.file("extdata", "tkmeans", "siz_MATLAB_tkmeans.csv", package = "fsdabridge"),
            header = FALSE
        )
    )
    storage.mode(matlab_siz) <- "double"

    matlab_idx <- as.integer(
        as.numeric(
            read.csv(
                system.file("extdata", "tkmeans", "idx_MATLAB_tkmeans.csv", package = "fsdabridge"),
                header = FALSE
            )[[1]]
        )
    )

    # -------------------------------------------------------------------
    # Normalize R-side shapes before comparing
    # -------------------------------------------------------------------
    result_idx <- as.integer(as.vector(result$idx))

    # -------------------------------------------------------------------
    # Align cluster labels between R and MATLAB (order is arbitrary)
    # -------------------------------------------------------------------
    perm <- match_labels(result$muopt, matlab_mu)

    mu_aligned <- result$muopt[perm, , drop = FALSE]

    relabel_map <- setNames(seq_along(perm), perm)
    idx_aligned <- ifelse(
        result_idx == 0,
        0L,
        as.integer(relabel_map[as.character(result_idx)])
    )

    siz_aligned <- result$siz[c(1, perm + 1), , drop = FALSE]

    # -------------------------------------------------------------------
    # Assertions
    # -------------------------------------------------------------------
    expect_lt(
        max(abs(mu_aligned - matlab_mu)),
        1e-9
    )

    expect_lt(
        abs(result$obj - matlab_obj),
        1e-9
    )

    expect_equal(
        siz_aligned[, 2:3],
        matlab_siz[, 2:3],
        ignore_attr = TRUE
    )

    expect_equal(
        idx_aligned,
        matlab_idx
    )
})
