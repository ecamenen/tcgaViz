plot_dynamic <- function(p) {
    p2 <- ggplotly(p) %>%
        plotly::config(
            editable = TRUE,
            displaylogo = FALSE,
            edits = list(shapePosition = FALSE),
            modeBarButtons = list(list("toImage")),
            toImageButtonOptions = list(
                filename = "tcga_plot.png",
                format = "png",
                width = 1000,
                height = 1000
            )
        ) %>%
        layout(margin = list(t = 100, r = 100))
    p2$x$layout$annotations[[2]]$x <- -0.075
    return(p2)
}
