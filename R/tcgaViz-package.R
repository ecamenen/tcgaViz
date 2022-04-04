#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import ggplot2 golem rlang rstatix shiny shinyFeedback
#' @importFrom config get
#' @importFrom data.table transpose
#' @importFrom dplyr mutate
#' @importFrom ggpubr ggviolin ggpar stat_pvalue_manual
#' @importFrom openxlsx read.xlsx
#' @importFrom readr read_delim
#' @importFrom reshape2 melt
#' @examples
#' # Load two data sets with the same cancer type and
#' # TCGA sample identifiers.
#' library(ggpubr)
#' data(tcga)
#' # Violin plot of cell subtypes and significance of a Wilcoxon adjusted test
#' # according to the expression level (high or low) of a selected gene.
#' df <- convert_biodata(tcga$genes, tcga$cells, select = "A")
#' p <- plot_violin(df, gene = "gene A")
#' stats <- calculate_pvalue(df)
#' p + stat_pvalue_manual(stats, label = "p.adj.signif")
## usethis namespace: end
NULL
