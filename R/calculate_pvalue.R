#' Corrected Wilcoxon tests
#'
#' Displays stars for each cell type corresponding to the significance level
#' of two mean comparison tests between expression levels (high or low) with
#' multiple correction.
#'
#' @inheritParams plot_violin
#' @param method_test character for the choice of the statistical test among
#' 't_test' or 'wilcox_test'.
#' @param method_adjust character for the choice of the multiple correction test
#' among `r paste0("'", paste0(sort(p.adjust.methods), collapse = "', '"), "'")`
#' @param p_threshold float for the significativity threshold of the P-value.
#'
#' @return rstatix_test object for a table with cell types in the row and
#' P-values, corrections and other statistics in the column.
#' @export
#'
#' @examples
#' data(tcga)
#' df <- (convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "A"
#' ))
#' calculate_pvalue(df)
#' calculate_pvalue(df, method_test = "t_test", method_adjust = "bonferroni")
calculate_pvalue <- function(
    data,
    method_test = "wilcox_test",
    method_adjust = "BH",
    p_threshold = 0.05
) {
    if (!method_test %in% c("t_test", "wilcox_test")) {
        stop("Please select an option between 't_test' or 'wilcox_test'")
    }
    if (!method_adjust %in% p.adjust.methods) {
        stop(
            paste0(
                "Please select an option in '",
                paste0(sort(p.adjust.methods), collapse = "', '"),
                "'"
            )
        )
    }
    stopifnot(is(data, "biodata"))
    stats <- data %>%
        remove_similar_type_levels() %>%
        group_by(cell_type) %>%
        base::get(method_test)(value ~ high) %>%
        adjust_pvalue(method = method_adjust) %>%
        add_significance() %>%
        subset(p.adj < p_threshold) %>%
        add_xy_position(x = "high")

    class(stats) <- c("biostats", class(stats))
    return(stats)
}
