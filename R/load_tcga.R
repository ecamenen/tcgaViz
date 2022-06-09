load_tcga <- function(path = NULL) {
    if (is.null(path)) {
        path <- system.file("extdata", package = "tcgaViz")
    }
    gene_names <- paste0("genes_", seq(3))
    for (f in c("cells", "phenotypes", gene_names)) {
        load(file.path(path, paste0(f, ".rda")))
    }
    list(
        cells = cells,
        phenotypes = phenotypes,
        genes = bind_rows(genes_1, genes_2, genes_3)
    )
}
