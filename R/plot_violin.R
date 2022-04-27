#' Violin plot expression
#'
#' Violin plot of cell subtypes according to the expression level (high or
#' low) of a selected gene.
#'
#' @param data dataframe containing columns named high (logical),
#' cell_type (factor) and value (float).
#' @param type character for the type of plot to be chosen among "violin"
#' or "boxplot".
#' @param dots boolean to add all data to the graph as points.
#' @param title character for the title of the plot.
#' @param xlab character for the name of the X axis label.
#' @param ylab character for the name of the X axis label.
#' @param ... arguments to pass to [ggplot2::theme()].
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
    type = "violin",
    dots = FALSE,
    title = NULL,
    xlab = NULL,
    ylab = NULL,
    ...
) {
    if (!type %in% c("violin", "boxplot")) {
        stop("Please select an option between 'violin' or 'boxplot'")
    }

    func <- quote(base::get(paste0("gg", type))(
        data = data,
        x = "high",
        y = "value",
        facet.by = "cell_type",
        outlier.shape = NA,
        color = "cell_type"
    ))

    if (type == "violin") {
        func$draw_quantiles <- c(0.25, 0.5, 0.75)
    }
    if (is.null(ylab)) {
        ylab <- ""
    }

    pop <- eval(func) +
        scale_x_discrete(
            name = xlab,
            labels = c(`FALSE` = "Low", `TRUE` = "High")
        ) +
        scale_y_log10(name = ylab) +
        labs(title = title) +
        theme(...)

    if (dots) {
        pop <- pop + geom_dotplot(
            binaxis = "y",
            stackdir = "center",
            alpha = .1,
            color = "gray",
            binwidth = .1,
            drop = TRUE,
            width = .5
        )
    }

    ggpar(pop, legend = "none")
}
