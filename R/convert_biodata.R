#' Format biological data
#'
#' Merges gene and cell datasets with the same TCGA sample identifiers,
#' splits samples according to the expression levels of a selected gene into
#' two categories (below or above average) and formats into a 3-column
#' data frame: gene expression levels, cell types, and gene expression values.
#'
#' @param genes data frame whose first two columns contain identifiers and the
#' others float values.
#' @param cells data frame whose first two columns contain identifiers and
#' the others float values.
#' @param select character for a column name in genes.
#' @param stat character for the statistic to be chosen among "mean", "median"
#' or "quantile".
#' @param disease character for the type of TCGA cancer (see the list in
#' extdata/disease_names.csv).
#' @param tissue character for the type of TCGA tissue among :
#' 'Additional - New Primary',
#' 'Additional Metastatic',
#' 'Metastatic',
#' 'Primary Blood Derived Cancer - Peripheral Blood',
#' 'Primary Tumor',
#' 'Recurrent Tumor',
#' 'Solid Tissue Normal'
#' @details `disease` and `tissue` arguments should be displayed in the title
#' of [plot.biodata()] only if the `genes` argument does not already have
#' them in its attributes.
#'
#' @return
#' data frame with the following columns:
#' \itemize{
#'     \item \code{high} (logical): the expression levels of a selected gene,
#'     TRUE for below or FALSE for above average.
#'     \item \code{cells} (factor): cell types.
#'     \item \code{value} (float): the abundance estimation of the cell types.
#' }
#' @export
#'
#' @examples
#' data(tcga)
#' (df_formatted <- convert_biodata(tcga$genes, tcga$cells$Cibersort, "ICOS"))
convert_biodata <- function(
    genes,
    cells,
    select = colnames(genes)[3],
    stat = "mean",
    disease = NULL,
    tissue = NULL
) {

    stat <- paste(tolower(stat))
    if (!stat %in% c("mean", "median", "quantile")) {
        stop("Please select an option between 'mean', 'median' or 'quantile'")
    }

    # Merge dataset
    data <- merge(cells, genes, by = 1)

    if (!is.null(attributes(genes)$disease) && is.null(disease)) {
        disease <- attributes(genes)$disease
    }
    if (!is.null(attributes(genes)$tissue) && is.null(tissue)) {
        tissue <- attributes(genes)$tissue
    }

    # Calculation of the gene expression median
    if (stat != "quantile") {
        func <- base::get(stat)(as.numeric(data[, select]), na.rm = TRUE)
        cutoff <- eval(quote(func))

        # Add a column for a higher level than the selected gene
        cutted <- mutate(
            data,
            high = ifelse(data[, select] > cutoff, "High", "Low")
        )
    } else {
        cutoff <- quantile(as.numeric(data[, select]), na.rm = TRUE)[c(2, 4)]

        data$high <- rep("")
        for (i in seq_along(data[, 1])) {
            if (data[i, select] < cutoff[1]) {
                data[i, "high"] <- names(cutoff)[1]
            }
            if (data[i, select] > cutoff[2]) {
                data[i, "high"] <- names(cutoff)[2]
            }
        }
        cutted <- data[data$high != "", ]
    }

    # Remove the samples, study and the gene columns
    cutted_melt <- subset(
        cutted,
        select = c(colnames(cells)[-seq(2)], "high")
    )
    cutted_melt$high <- as.factor(cutted_melt$high)

    if (length(levels(cutted_melt$high)) == 1) {
        stop(stop_msg_stat)
    }

    # Get a 3-column table with the value associated with each cell type
    # and its gene expression level
    sub_cutted_melt <- melt(cutted_melt, id.vars = "high") %>% tibble()
    colnames(sub_cutted_melt)[2] <- "cell_type"
    sub_cutted_melt$value <- sub_cutted_melt$value + 1e-05

    class(sub_cutted_melt) <- c("biodata", class(sub_cutted_melt))
    attributes(sub_cutted_melt)$disease <- disease
    attributes(sub_cutted_melt)$tissue <- tissue
    attributes(sub_cutted_melt)$gene <- select

    return(sub_cutted_melt)
}
