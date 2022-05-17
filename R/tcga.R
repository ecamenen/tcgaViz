#' Random biological data
#'
#' A list of biological data: RNASeq data, phenotypic
#' metadata and cell abundance.
#'
#' \itemize{
#'   \item \code{genes}: RNASeq from The Cancer Genome Atlas (TCGA) database.
#'   \item \code{phenotypes}: Metadata from the TCGA database containing
#' sample ID, sample type ID, sample type and primary disease.
#'   \item \code{cells}: Abundance estimates of cell types.
#' }
#' @note
#' RNASeq data are from a subset of invasive breast carcinoma data from
#' primary tumor tissue.  The cell type data are from a subset generated
#' by the Cibersort_ABS algorithm.
#' @source
#' \url{https://cancergenome.nih.gov/} \cr
#' \url{https://cibersort.stanford.edu/}
#' @examples
#' library(ggpubr)
#' data(tcga)
#' (df <- convert2biodata(
#'     algorithm = "Cibersort_ABS",
#'     disease = "breast invasive carcinoma",
#'     tissue = "Primary Tumor",
#'     gene_x = "ICOS"
#' ))
#' (stats <- calculate_pvalue(df))
#' plot(df, stats = stats)
#' @docType data
#' @keywords datasets
#' @name tcga
#' @usage data(tcga)
NULL
