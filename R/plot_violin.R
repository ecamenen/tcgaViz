#' Violin plot expression
#'
#' Violin plot of cell subtypes according to the expression level (high or
#' low) of a selected gene.
#'
#' @param data dataframe containing columns named high (logical),
#' cell_type (factor) and value (float).
#' @param gene character for the name of the gene plotted in the title.
#' @param type character for the type of plot to be chosen among "violin"
#' or "boxplot".
#' @param title character for the title of the plot.
#' @param label character for the title of the x-axis.
#' @param ... arguments to pass to ggplot::theme().
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
plot_violin <- function(
    data,
    gene = "Gene X",
    type = "violin",
    title = NULL,
    label = "value",
    ...) {
    if (!type %in% c("violin", "boxplot")) {
        stop("Please select an option between 'violin' or 'boxplot'")
    }

    func <- base::get(paste0("gg", type))(
        data = data,
        x = "high",
        y = "value",
        facet.by = "cell_type",
        outlier.shape = NA,
        draw_quantiles = c(0.25, 0.5, 0.75),
        color = "cell_type"
    )

    options(warn = -1)
    pop <- eval(quote(func)) +
        scale_x_discrete(
            name = paste(gene, "level"),
            labels = c(`FALSE` = "Low", `TRUE` = "High")
        ) +
        scale_y_log10() +
        labs(title = title) +
        ylab(label) +
        theme(...)
    options(warn = 0)
    ggpar(pop, legend = "none")
}
