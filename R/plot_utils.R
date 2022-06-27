#' Distribution plot
#'
#' Distribution plot of cell subtypes according to the expression level (high or
#' low) of a selected gene.
#'
#' @inheritParams ggplot2::theme
#' @param x object from [convert2biodata()] for a dataframe containing
#' columns named high (logical), cell_type (factor) and value (float).
#' @param type character for the type of plot to be chosen among "violin"
#' or "boxplot".
#' @param dots boolean to add all points to the graph.
#' @param title character for the title of the plot.
#' @param xlab character for the name of the X axis label.
#' @param ylab character for the name of the Y axis label.
#' @param stats object from [calculate_pvalue()].
#' @param draw bolean to plot the graph.
#' @param cex.lab numerical value giving the amount by which x and y plotting
#' labels should be magnified relative to the default.
#' @param cex.main numerical value giving the amount by which main plotting
#' title should be magnified relative to the default.
#' @param col character for the specification for the default plotting color.
#' See section 'Color Specification' in [graphics::par()].
#' @param ... arguments to pass to [ggplot2::theme()].
#' @return No return value, called for side effects
#' @export
#'
#' @examples
#' library("ggplot2")
#' data(tcga)
#' (df <- convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS"
#' ))
#' \donttest{
#' plot(df)
#' stats <- calculate_pvalue(df)
#' plot(
#'     df,
#'     stats = stats,
#'     type = "boxplot",
#'     dots = TRUE,
#'     xlab = "Expression level of the 'ICOS' gene by cell type",
#'     ylab = "Percent of relative abundance\n(from the Cibersort_ABS algorithm)",
#'     title = "Differential analysis of tumor tissue immune cell type abundance
#'     based on RNASeq gene-level expression from The Cancer Genome Atlas
#'     (TCGA) database",
#'     axis.text.y = element_text(size = 8, hjust = 0.5),
#'     plot.title =  element_text(face = "bold", hjust = 0.5)
#' )
#' }
plot.biodata <- function(
    x,
    type = "violin",
    dots = FALSE,
    title = NULL,
    xlab = NULL,
    ylab = NULL,
    stats = NULL,
    draw = TRUE,
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 8),
    cex.lab = 12,
    cex.main = 16,
    col = scales::hue_pal()(length(unique(x$cell_type))),
    axis.title.x = element_text(
        size = cex.lab,
        face = "bold.italic",
        vjust = -0.5
    ),
    axis.title.y = element_text(
        size = cex.lab,
        face = "bold.italic",
        vjust = -0.5
    ),
    plot.title = element_text(
        size = cex.main,
        face = "bold",
        vjust = 1,
        hjust = 0.5
    ),
    plot.margin = unit(c(0, 0, 0, -0.5), "cm"),
    ...
) {
    n <- length(unique(x$cell_type))
    if (length(col) != n) {
        stop(
            paste0(
                "the length of the `col` parameter vector must be the same",
                "size as the number of cell types, i.e. ",
                n,
                "."
            )
        )
    }
    p <- plot_distribution(
        x,
        type = type,
        dots = dots,
        title = title,
        xlab = xlab,
        ylab = ylab,
        stats = stats,
        axis.text.x = axis.text.x,
        axis.text.y = axis.text.y,
        axis.title.x = axis.title.x,
        axis.title.y = axis.title.y,
        plot.title =  plot.title,
        ...
    ) + scale_color_manual(
        values = col
    )
    if (draw) {
        suppressWarnings(plot(p))
    } else {
        return(p)
    }
}
