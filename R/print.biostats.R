#' @export
print.biostats <- function(x, ...) {
    cat(paste0(description.biostats(x), ".\n"))
    print(get_biostats(x), n = Inf)
}

name_columns <- function(x, y) {
    c(
        "Cell type",
        paste0("Average(", x, ")"),
        paste0("Average(", y, ")"),
        paste0("SD(", x, ")"),
        paste0("SD(", y, ")"),
        paste0("Average(", x, " - ", y, ")"),
        "P-value",
        "P-value adjusted",
        "Significance"
    )
}

get_biostats <- function(x) {
    stats <- x %>%
        select(cell_type, p, p.adj, p.adj.signif)

    stats_temp <- attributes(x)$args$data
    gene_levels <- c("75%", "25%")
    if (identical(levels(stats_temp$high), rev(gene_levels))) {
        levels(stats_temp$high) <- c("Low", "High")
        stats_temp$high <- factor(stats_temp$high, rev(levels(stats_temp$high)))
    } else {
        gene_levels <- levels(stats_temp$high)
    }
    stats_full <- stats_temp %>%
        group_by(cell_type, high) %>%
        summarise(avg = mean(value), sd = sd(value)) %>%
        pivot_wider(
            id_cols = cell_type,
            names_from = high,
            values_from = c("avg", "sd")
        ) %>%
        mutate(`High - Low` = avg_High - avg_Low) %>%
        relocate(`High - Low`, .after = sd_Low) %>%
        merge(stats) %>%
        tibble()

    colnames(stats_full) <- name_columns(gene_levels[1], gene_levels[2])
    return(stats_full)
}
