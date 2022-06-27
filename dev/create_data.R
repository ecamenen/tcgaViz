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

tcga <- list(cells = list(Cibersort_ABS = tibble(cells)), genes = tibble(genes), phenotypes = tibble(phenotypes))
usethis::use_data(tcga, overwrite = TRUE)

# genes_temp <- data.table::transpose(genes, keep.names = "sample")
# colnames(genes_temp) <- genes_temp[1, ]

###### Load raw data ######
library(readr)
library(openxlsx)
library(data.table)
library(dplyr)

gene_file <- "EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena"
cell_file <- "TCGA.xlsx"
phenotype_file <- "TCGA_phenotype_denseDataOnlyDownload.tsv"
path <- file.path(golem::get_golem_wd(), "inst", "extdata")

# Import the phenotypes file
sheets <- getSheetNames(file.path(path, cell_file))
cells <- list()
for (s in sheets) {
  temp <- tibble(data.frame(read.xlsx(file.path(path, cell_file), sheet = s)))
  temp$study <- as.factor(temp$study)
  cells <- c(cells, list(temp))
}
names(cells) <- sheets

# Import the tumor type file
phenotypes <- read_tsv(file.path(path, phenotype_file), trim_ws = FALSE)

# Double the buffer size
Sys.setenv(VROOM_CONNECTION_SIZE = 131072 * 2)
# Import the gene file
genes <- read_tsv(file.path(path, gene_file), trim_ws = FALSE)
#(init <- Sys.time())
genes2 <- transpose(genes, keep.names = "sample", make.names = "sample")
#Sys.time() - init
tcga = list(cells = cells, genes = tibble(genes2, .name_repair = "unique"), phenotypes = tibble(phenotypes))

tcga$phenotypes$sample_type <- as.factor(tcga$phenotypes$sample_type)
tcga$phenotypes$sample_type_id <- as.factor(tcga$phenotypes$sample_type_id)
tcga$phenotypes$`_primary_disease` <- as.factor(tcga$phenotypes$`_primary_disease`)
# colnames(tcga$genes)[grepl("\\.\\.\\.", colnames(tcga$genes))]
# tcga$genes[grepl("TCGA-06-0156-01.*", data.frame(tcga$genes)[, 1]), 1]
# tcga$genes[grepl(".*_.*", data.frame(tcga$genes)[, 1]), 1]
tcga$genes <- tcga$genes %>% rename(SLC35E2 = SLC35E2...16303, SLC35E2_1 = SLC35E2...16304)

usethis::use_data(tcga, overwrite = TRUE)

###### Divide the data ######

genes_1 <- tcga$genes[seq(3690), ]
genes_3 <- tcga$genes[ c((3690*2):nrow(tcga$genes)), ]
genes_2 <- tcga$genes[c(3691:(3690*2)), ]

for (f in c("cells", "phenotypes", paste0("genes_", seq(3)))) {
    usethis::use_data(f, overwrite = TRUE)
}

###### Subset of raw data ######

algorithm <- "Cibersort_ABS"
disease <- "breast invasive carcinoma"
gene_x <- "ICOS"
tissue <- "Primary Tumor"

diseases <- tcga$phenotypes
if (!is.null(disease)) {
  diseases <- diseases[diseases$`_primary_disease` == tolower(disease),]
}
phenotypes <- diseases[diseases$sample_type == tissue,]
genes <- tcga$genes[tcga$genes$sample %in% phenotypes$sample, c(1, which(colnames(tcga$genes) == gene_x))]
cells <- tcga$cells[[algorithm]][tcga$cells[[algorithm]]$sample %in% phenotypes$sample, ]

rows <- sample(tcga$cells$Cibersort_ABS$sample, 30)

cells <- cells[cells$sample %in% rows, ]
phenotypes <- phenotypes[phenotypes$sample %in% rows, ]
genes <- genes[genes$sample %in% rows, ]

identical(sort(tcga$genes$sample), sort(tcga$phenotypes$sample))

tcga = list(cells = list(Cibersort_ABS = tibble(cells)), genes = tibble(genes), phenotypes = tibble(phenotypes))
usethis::use_data(tcga, overwrite = TRUE)

###### Controlled vocabulary ######

metadata <- list()
for (x in c("disease", "algorithm", "tissue", "gene")) {
    metadata[[x]] <- read.csv(file.path(path, paste0(x, "_list.csv")), header = FALSE)
}
usethis::use_data(metadata, overwrite = TRUE, internal = TRUE)

###### Descriptive statistics ######

dataset <- merge(tcga$phenotypes, tcga$genes, by = 1)

tcga$phenotypes %>%
  group_by(`_primary_disease`, sample_type) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>%
  arrange(desc(n))

name_cells <- lapply(
  names(tcga$cells),
  function(x) colnames(tcga$cells[[x]])[-seq(2)]
)


temp <- tcga$phenotypes %>%
  merge(tcga$cells[[1]])

temp %>%
  summarise(
    across(
      all_of(colnames(tcga$cells[[1]])[-seq(2)]),
      list(
        mean = ~ mean(.x, na.rm = TRUE),
        sd = ~ sd(.x, na.rm = TRUE)
        ),
      .names = "{.col}.{.fn}"
      )
    )

mean_stats <- temp %>%
  summarise(
  across(
    all_of(colnames(tcga$cells[[1]])[-seq(2)]),
    list(~ mean(.x, na.rm = TRUE)),
  .names = "{.col}"
  ))

sd_stats <- temp %>%
  summarise(
    across(
      all_of(colnames(tcga$cells[[1]])[-seq(2)]),
      list(~ sd(.x, na.rm = TRUE)),
      .names = "{.col}"
    ))

t(rbind(sd_stats, mean_stats))
