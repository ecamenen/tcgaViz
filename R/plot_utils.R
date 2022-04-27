#' @export
plot.biodata <- function(
    x,
    type = "violin",
    dots = FALSE,
    title = NULL,
    xlab = NULL,
    ylab = NULL,
    stats = NULL,
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 8),
    axis.title.x = element_text(size = 12, face = "bold.italic", vjust = -0.5),
    axis.title.y = element_text(size = 12, face = "bold.italic", vjust = -0.5),
    plot.title =  element_text(size = 16, face = "bold", vjust = 1, hjust = 0.5),
    ...
) {
    plot_violin(
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
    )
}
