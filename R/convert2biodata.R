#' @inherit convert_biodata return description title params
#' @param algorithm character for the algorithm used to estimate the
#' distribution of cell type abundance among : 'Cibersort', 'Cibersort_ABS',
#' 'EPIC', 'MCP_counter', 'Quantiseq', 'Timer', 'Xcell', 'Xcell (2)' and
#' 'Xcell64'.
#' @param gene_x character for the gene selected in the differential analysis
#' (see the list in extdata/gene_names.csv).
#' @param path character for the path name of the `tcga` dataset.
#'
#' @export
#'
#' @examples
#' data(tcga)
#' (convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS"
#' ))
convert2biodata <- function(
    algorithm,
    disease,
    tissue,
    gene_x,
    stat = "mean",
    path = "."
) {
    if (!exists("tcga")) {
        message("TCGA loading in progess...")
        file <- file.path(path, "tcga.rda")
        if (file.exists(file)) {
            load(file)
        } else {
            stop(paste0(file, " does not exists."))
        }
    }

    # Import the phenotypes file
    algorithm <- paste(algorithm)
    check_list(algorithm, "algorithm")
    tcga_pop <- tcga$cells[[algorithm]]

    disease <- paste(disease)
    check_list(disease, "disease")
    # Import the tumor type file
    diseases <- tcga$phenotypes
    if (!is.null(disease)) {
        diseases <- diseases[
            diseases$`_primary_disease` == tolower(disease),
        ]
    }

    tissue <- paste(tissue)
    check_list(tissue, "tissue")
    tumor_type <- diseases
    if (!is.null(tissue)) {
        tumor_type <- diseases[
            diseases$sample_type == tissue,
            "sample",
            drop = FALSE
        ]
        if (nrow(tumor_type) == 0) {
            stop("Selected tissue has 0 element.")
        }
    }

    # Import the gene file
    gene_x <- paste(gene_x)
    check_list(gene_x, "gene")
    gene <- tcga$genes[, c(1, which(colnames(tcga$genes) == gene_x))]

    # Merge datasets
    dataset <- merge(tumor_type, gene, by = 1)
    attributes(dataset)$disease <- disease
    attributes(dataset)$tissue <- tissue

    # Data formatting
    convert_biodata(dataset, tcga_pop, gene_x, stat)
}
