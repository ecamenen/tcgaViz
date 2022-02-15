path <- system.file("extdata", package = "tcgaViz")

set_file <- function(name) {
    list(
        datapath = file.path(path, name),
        name = name
    )
}

test_that("reactives and output updates", {
    testServer(app_server, {
        session$setInputs(
            cell_file = set_file("cell_pop.xlsx"),
            phenotype_file = set_file("tcga_phenotypes.tsv"),
            gene_file = set_file("tcga_genes.tsv")
        )

        for (i in c("cells", "phenotypes", "genes")) {
            expect_is(vars[[i]], "data.frame")
            expect_equal(nrow(vars[[i]]), 30)
            if (i < 3) {
                expect_equal(vars[[i]][, 1], paste0("TCGA.", seq(30)))
            }
        }

        expect_equal(colnames(vars$phenotypes), "sample")
        expect_equal(
            colnames(vars$cells),
            c("sample", "study", paste0("X", seq(5)))
        )
        expect_equal(colnames(vars$genes), c("col", LETTERS[seq(5)]))
        expect_equal(unique(vars$cells[, 2]), "BRCA")
        expect_true(all(vars$cells[, 3:7] <= 1))
        expect_true(
            all(
                sapply(c(2:6),
                       function(x) is(vars$genes[, x], "numeric"))
                )
            )

        colnames(vars$genes)[1] <- "sample"
        vars$genes <- vars$genes[order(vars$genes$sample), ]
        rownames(vars$genes) <- seq(30)
        expect_equal(vars$dataset, vars$genes)

        output$violin_plot
    })
})
