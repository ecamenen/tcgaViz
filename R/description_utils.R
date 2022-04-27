description <- function(x) {
    UseMethod("description")
}

description.biodata <- function(x) {
    if (!is.null(attributes(x)$disease)) {
        tissue <- attributes(x)$tissue
        if (!is.null(tissue)) {
            tissue <- paste0(" (", tissue, ")")
        }
        paste0(str_to_title(attributes(x)$disease), tissue)
    } else {
        NULL
    }
}

description.biostats <- function(x) {
    properties <- attributes(x)$args

    if (properties$method == "wilcox_test") {
        name_test <- "Wilcoxon-Mann-Whitney test"
    } else {
        name_test <- "Student's t-test"
    }

    paste0(
        description.biodata(properties$data),
        "\n",
        name_test,
        " with ",
        properties$p.adjust.method,
        " correction (n_low = ",
        x[1, ]$n1,
        "; n_high = ",
        x[1, ]$n2,
        ")"
    )
}
