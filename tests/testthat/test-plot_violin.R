n <- 100
k <- 10
high <- as.logical(rbinom(n * k, 1, 0.5))
cell_type <- factor(rep(LETTERS[seq(k)], each = n))
value <- runif(n * k, max = .01)
df <- data.frame(high, cell_type, value)

test_that("plot_violin works", {
    p <- plot_violin(df, "gene X")
    expect_is(p, "ggplot")
    expect_identical(
        p$labels,
        list(x = "high", y = "value", colour = "cell_type")
    )
})
