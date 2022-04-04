#' Format biological data
#'
#' Merges gene and cell datasets with the same TCGA sample identifiers,
#' splits samples according to the expression levels of a selected gene into
#' two categories (below or above average) and formats into a 3-column
#' data frame: gene expression levels, cell types, and gene expression values.
#'
#' @param gene data frame whose first two columns contain identifiers and the
#' others float values.
#' @param cell_type data frame whose first two columns contain identifiers and
#' the others float values.
#' @param select character for a column name in gene.
#'
#' @return
#' data frame with the following columns:
#' \itemize{
#'     \item \code{high} (logical): the expression levels of a selected gene,
#'     TRUE for below or FALSE for above average.
#'     \item \code{cell_type} (factor): cell types.
#'     \item \code{value} (float): the abundance estimation of the cell types.
#' }
#' @export
#'
#' @examples
#' data(tcga)
#' (df_formatted <- convert_biodata(tcga$genes, tcga$cells, "A"))
convert_biodata <- function(
    gene,
    cell_type,
    select = colnames(gene)[3],
    stat = c("mean", "median", "quantile")
) {

    # Merge dataset
    data <- merge(cell_type, gene, by = 1)

    # Calculation of the gene expression median
    func <- base::get(stat)(as.numeric(data[, select]), na.rm = TRUE)
    cutoff <- eval(quote(func))

    # Add a column for a higher level than the selected gene
    cutted <- mutate(data, high = data[, select] > cutoff)

    # Remove the samples, study and the gene columns
    cutted_melt <- subset(
        cutted,
        select = c(colnames(cell_type)[-seq(2)], "high")
    )

    # Get a 3-column table with the value associated with each cell type
    # and its gene expression level
    sub_cutted_melt <- melt(cutted_melt, id.vars = "high")
    colnames(sub_cutted_melt)[2] <- "cell_type"
    sub_cutted_melt$value <- sub_cutted_melt$value + 1e-05

    return(sub_cutted_melt)
}
