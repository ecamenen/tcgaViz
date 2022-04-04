#' Corrected Wilcoxon tests
#'
#' Displays stars for each cell type corresponding to the significance level
#' of Wilcoxon tests between expression levels (high or low) with
#' Benjamini-Hochberg multiple correction.
#'
#' @inheritParams plot_violin
#' @param p_threshold float for the significativity threshold of the P-value.
#'
#' @return rstatix_test object for a table with cell types in the row and
#' P-values, corrections and other statistics in the column.
#' @export
#'
#' @examples
#' data(tcga)
#' df <- convert_biodata(tcga$genes, tcga$cells, "A")
#' stats <- calculate_pvalue(df)
calculate_pvalue <- function(data, p_threshold = 0.05) {
    data %>%
        remove_similar_type_levels() %>%
        group_by(cell_type) %>%
        wilcox_test(value ~ high) %>%
        adjust_pvalue(method = "BH") %>%
        add_significance() %>%
        subset(p.adj < p_threshold) %>%
        add_xy_position(x = "high")
}
