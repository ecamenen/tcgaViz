#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import DT golem grDevices plotly rlang rstatix shinyFeedback shinyjs
#' stringr tidyr tidyselect utils
#' @importFrom config get
#' @importFrom data.table transpose
#' @importFrom dplyr mutate relocate bind_rows
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
#' # Load the dataset with the same cancer type and
#' # TCGA sample identifiers.
#' library(ggpubr)
#' data(tcga)
#' # Violin plot of cell subtypes and significance of a Wilcoxon adjusted test
#' # according to the expression level (high or low) of a selected gene.
#' (df <- convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS"
#' ))
#' (stats <- calculate_pvalue(df))
#' plot(df, stats = stats)
#' # Advanced parameters
#' (df <- convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS",
#'     stat = "quantile"
#' ))
#' (stats <- calculate_pvalue(
#'     df,
#'     method_test = "t_test",
#'     method_adjust = "bonferroni",
#'     p_threshold = 0.01
#' ))
#' plot(
#'     df,
#'     stats = stats,
#'     type = "boxplot",
#'     dots = TRUE,
#'     xlab = "Expression level of the 'ICOS' gene by cell type",
#'     ylab = "Percent of relative abundance\n(from the Cibersort_ABS algorithm)",
#'     title = toupper("Differential analysis of immune cell type abundance
#'     based on RNASeq gene-level expression from The Cancer Genome Atlas"),
#'     axis.text.y = element_text(size = 8, hjust = 0.5),
#'     plot.title =  element_text(face = "bold", hjust = 0.5),
#'     plot.subtitle =  element_text(size = , face = "italic", hjust = 0.5),
#'     draw = FALSE
#' ) + labs(
#'     subtitle = paste(
#'         "Breast Invasive Carcinoma (BRCA; Primary Tumor):",
#'         "Student's t-test with Bonferroni (P < 0.01)"
#'     )
#' )
## usethis namespace: end
NULL
