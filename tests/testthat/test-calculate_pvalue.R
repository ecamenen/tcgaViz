n <- 100
k <- 10
high <- as.logical(rbinom(n * k, 1, 0.5))
cell_type <- factor(rep(LETTERS[seq(k)], each = n))
value <- runif(n * k, max = .01)
df <- data.frame(high, cell_type, value)

test_that("calculate_pvalue works", {
    stats <- calculate_pvalue(df, p_threshold = 1)
    expect_is(stats, "rstatix_test")
    expect_equal(as.character.factor(stats$cell_type), LETTERS[seq(k)])
    expect_match(as.character(unique(stats[, ".y."])), "value")
    expect_false(as.logical(unique(stats$group1)))
    expect_true(as.logical(unique(stats$group2)))
    for (x in c("n1", "n2", "statistic")) {
        expect_true(all(stats[, x] > 0))
    }
    expect_equal(unique(stats$xmax), 2)
    expect_equal(unique(stats$xmin), 1)
    for (x in c("p", "p.adj", "y.position")) {
        expect_true(all(stats[, x] <= 1))
    }
    expect_true(all(stats$p.adj.signif %in% c("ns", "*", "**", "***")))
})
