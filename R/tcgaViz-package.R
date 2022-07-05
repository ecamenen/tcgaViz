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
#' @seealso
#' \itemize{
#' \item [Contribute to the development](https://github.com/ecamenen/tcgaViz)
#' \item [Report bugs](https://github.com/ecamenen/tcgaViz/issues)
#' \item [Read the tutorial](https://github.com/ecamenen/tcgaViz/blob/master/doc/Tutorial.pdf)
#' }
#' @keywords internal
"_PACKAGE"
