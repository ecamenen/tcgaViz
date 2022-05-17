description <- function(x) {
    UseMethod("description")
}

get_disease_abbreviation <- function(disease) {
    path <- file.path(golem::get_golem_wd(), "inst", "extdata")
    file_path <- file.path(path, "disease_list.csv")
    file <- read.csv(file_path, header = FALSE)
    diseases <- as.list(file[, 2])
    names(diseases) <- file[, 1]
    return(diseases[[tolower(disease)]])
}

description.biodata <- function(x) {
    if (!is.null(attributes(x)$disease)) {
        paste0(
            str_to_title(attributes(x)$disease),
            " (",
            get_disease_abbreviation(attributes(x)$disease),
            "; ",
            attributes(x)$tissue,
            ")"
        )
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

    if (properties$p.adjust.method == "BH") {
        properties$p.adjust.method <- "Benjamini & Hochberg"
    } else if (properties$p.adjust.method == "BY") {
        properties$p.adjust.method <- "Benjamini & Yekutieli"
    } else {
        str_to_title(properties$p.adjust.method)
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
