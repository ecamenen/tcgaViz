plot_dynamic <- function(p) {
    ggplotly(p) %>%
        plotly::config(
            editable = TRUE,
            displaylogo = FALSE,
            edits = list(shapePosition = F),
            modeBarButtons = list(list("toImage")),
            toImageButtonOptions = list(
                filename = "tcga_plot.png",
                format = "png",
                width = 1000,
                height = 1000
            )
        )
}
