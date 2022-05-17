#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import DT golem grDevices plotly rlang rstatix shinyFeedback shinyjs
#' stringr tidyr tidyselect utils
#' @importFrom config get
#' @importFrom data.table transpose
#' @importFrom dplyr mutate relocate
#' @importFrom ggpubr ggviolin ggboxplot ggpar stat_pvalue_manual
#' @importFrom openxlsx read.xlsx
#' @importFrom readr read_delim
#' @importFrom reshape2 melt
#' @importFrom methods is
#' @importFrom stats quantile p.adjust.methods sd
#' @importFrom magrittr %>%
#' @rawNamespace import(ggplot2, except = last_plot)
#' @rawNamespace import(shiny, except = c(dataTableOutput, renderDataTable, runExample))
#' @examples
#' # Load two data sets with the same cancer type and
#' # TCGA sample identifiers.
#' library(ggpubr)
#' data(tcga)
#' # Violin plot of cell subtypes and significance of a Wilcoxon adjusted test
#' # according to the expression level (high or low) of a selected gene.
#' df <- (convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "A"
#' ))
#' stats <- calculate_pvalue(df)
#' plot_violin(df, stats = stats)
## usethis namespace: end
NULL
