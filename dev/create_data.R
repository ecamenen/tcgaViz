###### Create random data ###### 
n <- 30
p <- 5
i_sign <- round(n * 1/4)

val_sign <- sapply(
    seq(i_sign),
    function(x) c(runif(p, max = 10), runif(p, min = .1, max = .25))
)
val_n_sign <- sapply(
    seq(n - i_sign),
    function(x) c(rep(0, p), runif(p, max = .05))
)
tab <- cbind(val_sign, val_n_sign)

sample <- paste0("TCGA.", seq(n))
colnames(tab) <- sample

cells <- data.frame(sample, study = "BRCA", t(tab[(p + 1):NROW(tab), ]))
rownames(cells) <- seq(n)
genes <- data.frame(sample = LETTERS[seq(p)], tab[seq(p), ])
phenotypes <- data.frame(sample, 1, "Primary Tumor", "breast invasive carcinoma")
colnames(phenotypes)[2:4] <- c("sample_type_id", "sample_type", "_primary_disease")

path <- file.path("inst", "extdata")
openxlsx::write.xlsx(
    cells,
    file.path(path, "cell_pop.xlsx"),
    sheetName = "Cibersort_ABS"
)
readr::write_tsv(genes, file.path(path, "tcga_genes.tsv"))
readr::write_tsv(phenotypes, file.path(path, "tcga_phenotypes.tsv"))

genes_temp <- data.table::transpose(genes, keep.names = "sample")
colnames(genes_temp) <- genes_temp[1, ]
tcga_random = list(cells = cells, genes = genes_temp[-1, ], phenotypes = phenotypes)
usethis::use_data(tcga_random, overwrite = TRUE)

###### Load raw data ######

gene_file <- "EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena"
cell_file <- "TCGA.xlsx"
phenotype_file <- "TCGA_phenotype_denseDataOnlyDownload.tsv"
path <- file.path("~", "inst", "extdata", "CIMI")

# Import the phenotypes file
sheets <- getSheetNames(file.path(path, cell_file))
cells <- list()
for (s in sheets) {
  temp <- data.frame(read.xlsx(file.path(path, cell_file), sheet = s))
  cells <- c(cells, list(temp))
}
names(cells) <- sheets

# Import the tumor type file
phenotypes <- read_delim(file.path(path, phenotype_file), show_col_types = FALSE)

# Double the buffer size
Sys.setenv(VROOM_CONNECTION_SIZE = 131072 * 2)
# Import the gene file
genes <- read_delim(file.path(path, gene_file), show_col_types = FALSE)
genes <- transpose(genes, keep.names = "col", make.names = "sample")
tcga_raw <- list(cells = cells, genes = genes, phenotypes = phenotypes)
usethis::use_data(tcga_raw, overwrite = TRUE)
