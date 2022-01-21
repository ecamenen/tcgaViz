#' Random biological data
#'
#' A list of randomly generated biological data: RNASeq data, phenotypic
#' metadata and cell abundance.
#'
#' \itemize{
#'   \item \code{genes}: Random data based on the RNASeq distribution of The
#' Cancer Genome Atlas (TCGA) database.
#'   \item \code{phenotypes}: Metadata based on the breast cancer model from
#' the TCGA database containing sample ID, sample type ID, sample type and
#' primary disease.
#'   \item \code{cells}: Random data based on the distribution of abundance
#' estimates of certain cell types using the Cibersort algorithm.
#' }
#' @source
#' \url{https://cancergenome.nih.gov/} \cr
#' \url{https://cibersort.stanford.edu/}
#' @examples
#' library(ggpubr)
#' data(tcga)
#' df <- convert_biodata(tcga$genes, tcga$cells, select = "A")
#' p <- plot_violin(df, gene = "gene A")
#' stats <- calculate_pvalue(df)
#' p + stat_pvalue_manual(stats, label = "p.adj.signif")
#' @format A list of 3 data frames each containing 10 individuals and 5
#' numeric variables.
#' @docType data
#' @keywords datasets
#' @name tcga
#' @usage data(tcga)
NULL
