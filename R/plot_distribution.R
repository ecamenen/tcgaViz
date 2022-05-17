#' @inherit plot.biodata examples params description title
#' @return ggpubr object for a distribution plot.
#' @noRd
#' @examples
#' library("ggplot2")
#' data(tcga)
#' (df <- convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS"
#' ))
#' plot_distribution(df)
#' stats <- calculate_pvalue(df)
#' plot_distribution(
#'     df,
#'     stats = stats,
#'     type = "boxplot",
#'     dots = TRUE,
#'     xlab = "Expression level of the 'ICOS' gene by cell type",
#'     ylab = "Percent of relative abundance\n(from the Cibersort_ABS algorithm)",
#'     title = toupper("Differential analysis of immune cell type abundance
#'     based on RNASeq gene-level expression from The Cancer Genome Atlas"),
#'     axis.text.y = element_text(size = 8, hjust = 0.5),
#'     plot.title = element_text(face = "bold", hjust = 0.5),
#'     plot.subtitle = element_text(size = , face = "italic", hjust = 0.5)
#' ) + labs(
#'     subtitle = paste(
#'         "Breast Invasive Carcinoma (BRCA; Primary Tumor):",
#'         "Wilcoxon-Mann-Whitney test with Benjamini & Hochberg correction"
#'     )
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
