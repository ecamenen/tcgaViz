#' @export
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
        options(warn = -1)
        plot(p)
        options(warn = 0)
    } else {
        return(p)
    }
}
