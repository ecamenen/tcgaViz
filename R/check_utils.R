stop_msg_stat <- paste(
    "One of the quantiles has no value.",
    "Please select another statistic."
)

check_colors <- function(colors) {
    if (!is.null(colors)) {
        colors <- as.vector(colors)
        for (i in colors) {
            if (!is.na(i) && !(i %in% colors()) && is_character(i) &&
                regexpr("^#{1}[a-zA-Z0-9]{6,8}$", i) < 1) {
                stop("colors must be in colors() or a rgb character.")
            }
        }
    }
}

# check_list("ARL17A", "gene")
# check_list("acute myeloid leukemia2", "disease")
# "'acute myeloid leukemia2' is not in the disease list.
# Please check in [...]/extdata/disease_list.csv."
check_list <- function(x, y) {
    x <- paste(x)
    y <- paste(y)
    if (y == "disease") {
        x <- tolower(x)
    }
    file_path <- file.path(
        system.file("extdata", package = "tcgaViz"),
        paste0(y, "_list.csv")
    )
    metadata <- get0("metadata", envir = asNamespace("tcgaViz"))
    if (!x %in% metadata[[y]][, 1]) {
        stop(
            paste0(
                "'",
                x,
                "' is not in the ",
                y,
                " list. Please, check in ",
                file_path,
                "."
            )
        )
    }
}

#' @examples
#' data(tcga)
#' (df <- convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS"
#' ))
#' check_object(df, "biodata")
#' wrong <- NULL
#' check_object(wrong, "biodata")
#' # wrong must be a biodata object. Check ?convert2biodata().
#' stats <- calculate_pvalue(df)
#' check_object(stats, "biostats")
#' check_object(stats2, "biostats")
#' # wrong must be a biostats object. Check ?calculate_pvalue().
#' @noRd
check_object <- function(x, y) {
    func <- ifelse(y == "biodata", "convert2biodata()", "calculate_pvalue()")
    if (!is(x, y)) {
        stop(
            paste0(
                deparse(substitute(x)),
                " must be a ",
                y,
                "object. Please check ?",
                func,
                "."
            )
        )
    }
}

# y <- 0.05
# check_type(y, "double")
# check_type(y, "bool")
# "y must be a bool."
check_type <- function(x, y) {
    if (!base::get(paste0("is_", y))(x)) {
        stop(paste0(deparse(substitute(x)), " must be a ", y, "."))
    }
}
