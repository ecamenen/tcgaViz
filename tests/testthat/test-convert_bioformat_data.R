n <- 3
k <- 2
values <- c(0.3, 0.5, 0.87, 0.93, 0.69, 0.02, 0.44, 0.77, 0.1, 0.65, 0.3, 0.35)
df <- data.frame(
    paste0("TCGA-", seq(n)),
    rep("BRCA", n),
    matrix(values, n, k * 2)
)
colnames(df) <- c("sample", "study", LETTERS[seq(k)], letters[seq(k)])
cells <- df[, seq(k + 2)]
genes <- df[, c(seq(2), (k + 3):length(df))]

test_that("convert_biodata works", {
    df_formatted <- convert_biodata(genes, cells, "a")
    expect_is(df_formatted, "data.frame")
    expect_setequal(colnames(df_formatted), c("high", "cell_type", "value"))
    expect_setequal(df_formatted$high, rep(c(TRUE, TRUE, FALSE), 2))
    expect_setequal(
        as.character.factor(df_formatted$cell_type),
        rep(c("A", "B"), each = 3)
    )
    expect_setequal(df_formatted$value, values[seq(n * k)] + 1e-05)
})
