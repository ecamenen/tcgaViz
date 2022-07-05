#' Corrected Wilcoxon tests
#'
#' Displays stars for each cell type corresponding to the significance level
#' of two mean comparison tests between expression levels (high or low) with
#' multiple correction.
#'
#' @inheritParams plot.biodata
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
#' (df <- convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS"
#' ))
#' \donttest{
#' calculate_pvalue(df)
#' }
#' calculate_pvalue(
#'     df,
#'     method_test = "t_test",
#'     method_adjust = "bonferroni",
#'     p_threshold = 0.01
#' )
calculate_pvalue <- function(
    x,
    method_test = "wilcox_test",
    method_adjust = "BH",
    p_threshold = 0.05
) {
    method_test <- paste(tolower(method_test))
    if (!method_test %in% c("t_test", "wilcox_test")) {
        stop("Please select an option between 't_test' or 'wilcox_test'")
    }
    method_adjust <- paste(method_adjust)
    if (!method_adjust %in% p.adjust.methods) {
        stop(
            paste0(
                "Please select an option in '",
                paste0(sort(p.adjust.methods), collapse = "', '"),
                "'"
            )
        )
    }
    check_object(x, "biodata")
    check_type(p_threshold, "double")
    if (p_threshold > 1 | p_threshold < 0) {
        stop("p_threshold must be comprise between 1 and 0.")
    }

    stats <- x %>%
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
