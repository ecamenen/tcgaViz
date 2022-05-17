#' Violin plot expression
#'
#' Violin plot of cell subtypes according to the expression level (high or
#' low) of a selected gene.
#'
#' @param data object from [convert2biodata()] for a dataframe containing
#' columns named high (logical), cell_type (factor) and value (float).
#' @param type character for the type of plot to be chosen among "violin"
#' or "boxplot".
#' @param dots boolean to add all data to the graph as points.
#' @param title character for the title of the plot.
#' @param xlab character for the name of the X axis label.
#' @param ylab character for the name of the X axis label.
#' @param stats object from [calculate_pvalue()].
#' @param ... arguments to pass to [ggplot2::theme()].
#'
#' @return ggrub object for a violon plot.
#' @export
#'
#' @examples
#' library("ggplot2")
#' data(tcga)
#' df <- (convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "A"
#' ))
#' plot_violin(df)
#' stats <- calculate_pvalue(df)
#' plot_violin(
#'     df,
#'     type = "boxplot",
#'     dots = TRUE,
#'     xlab = "Level of cell type differentiation from the Cibersort_ABS algorithm
#'     based on the 'A' gene expression.",
#'     ylab = "Percent of relative abundance",
#'     title = "Random distribution from TCGA database",
#'     stats = stats,
#'     axis.text.y = element_text(size = 8),
#'     axis.title = element_text(face = "bold.italic"),
#'     plot.title =  element_text(face = "bold", hjust = 0.5)
#' )
plot_distribution <- function(
    x,
    stats = NULL,
    type = "violin",
    dots = FALSE,
    title = NULL,
    xlab = NULL,
    ylab = NULL,
    ...
) {
    type <- paste(tolower(type))
    if (!type %in% c("violin", "boxplot")) {
        stop("Please select an option between 'violin' or 'boxplot'")
    }
    check_object(x, "biodata")
    if (!is.null(stats)) {
        check_object(stats, "biostats")
    }
    check_type(dots, "bool")

    func <- quote(base::get(paste0("gg", type))(
        data = x,
        x = "high",
        y = "value",
        facet.by = "cell_type",
        outlier.shape = NA,
        color = "cell_type"
    ))

    if (type == "violin") {
        func$draw_quantiles <- c(0.25, 0.5, 0.75)
    }
    if (is.null(title)) {
        if (is.null(stats)) {
            title <- description.biodata(x)
        } else {
            title <- description.biostats(stats)
        }
    }
    if (is.null(xlab)) {
        xlab <- paste(
            "Level of cell type differentiation based on the",
            attributes(x)$gene,
            "gene expression"
        )
    }

    title <- paste(title)
    xlab <- paste(xlab)
    ylab <- paste(ylab)

    pop <- eval(func) +
        scale_x_discrete(name = xlab) +
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

    p <- ggpar(pop, legend = "none")

    if (!is.null(stats)) {
        p <- p + ggpubr::stat_pvalue_manual(stats, label = "p.adj.signif")
    }

    return(p)
}
