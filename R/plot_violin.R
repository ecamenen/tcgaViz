#' Violin plot expression
#'
#' Violin plot of cell subtypes according to the expression level (high or
#' low) of a selected gene.
#'
#' @param data dataframe containing columns named high (logical),
#' cell_type (factor) and value (float).
#' @param gene character for the name of the gene plotted in the title.
#'
#' @return ggrub object for a violon plot.
#' @export
#'
#' @examples
#' library(ggpubr)
#' data(tcga)
#' df <- convert_biodata(tcga$genes, tcga$cells, "A")
#' p <- plot_violin(df)
#' stats <- calculate_pvalue(df)
#' p + stat_pvalue_manual(stats, label = "p.adj.signif")
plot_violin <- function(data, gene = "Gene X") {
    pop <- ggviolin(
        data = data,
        x = "high",
        y = "value",
        facet.by = "cell_type",
        outlier.shape = NA,
        color = "cell_type"
    ) +
        scale_x_discrete(
            name = paste(gene, "level"),
            labels = c(`FALSE` = "Low", `TRUE` = "High")
        ) +
        scale_y_log10()
    ggpar(pop, legend = "none")
}
