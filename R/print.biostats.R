#' @export
summary.biostats <- function(x) {
    cat(paste0(description.biostats(x), ".\n"))

    stats <- x %>%
        select(cell_type, p, p.adj, p.adj.signif)

    attributes(x)$args$data %>%
        group_by(cell_type, high) %>%
        summarise(avg = mean(value), sd = sd(value)) %>%
        pivot_wider(
            id_cols = cell_type,
            names_from = high,
            values_from = c("avg", "sd")
        ) %>%
        mutate(`High - Low` = avg_High - avg_Low) %>%
        relocate(`High - Low`, .after = avg_High) %>%
        merge(stats) %>%
        tibble() %>%
        print(n = Inf)
}
