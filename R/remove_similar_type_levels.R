remove_similar_type_levels <- function(data) {
    options(dplyr.summarise.inform = FALSE)

    temp <- data %>%
        group_by(cell_type, high) %>%
        dplyr::summarise(avg = mean(value))

    to_keep <- NULL

    for (i in seq(nrow(temp))) {
        if (i %% 2 == 0) {
            if (temp[i, "avg"] - temp[i - 1, "avg"] != 0) {
                to_keep <- c(
                    to_keep,
                    levels(data$cell_type)[as.numeric(temp[i, "cell_type"])]
                )
            }
        }
    }
    data <- data[data$cell_type %in% to_keep, ]
    levels(data) <- to_keep
    return(data)
}
