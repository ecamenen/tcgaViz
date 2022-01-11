# A visualization tool to depict proportions of immune cells in any tumors
# relative to the average expression of any gene (or signature).

########## Environment setting ##########

# Input variables
algorithm <- "Cibersort_ABS"
disease <- "breast invasive carcinoma"
gene_x <- "ICOS"

# Library loading
library(openxlsx)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(rstatix)
library(reshape2)
library(readr)
library(data.table)

setwd("Documents/TCGA/")

########## Dataset loading ##########

# Import the phenotypes file
tcga_pop <- read.xlsx("TCGA.xlsx", sheet = algorithm)

# Import the tumor type file
tumor_type <- read_delim("TCGA_phenotype_denseDataOnlyDownload.tsv")
if (!is.null(disease)) {
    tumor_type <- subset(
        tumor_type,
        subset = `_primary_disease` == disease,
        select = "sample"
    )
}

# Double the buffer size
Sys.setenv(VROOM_CONNECTION_SIZE = 131072 * 2)
# Import the gene file
gene <- read_tsv("EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena.gz")
gene <- transpose(gene, keep.names = "col", make.names = "sample")

# Merge datasets
dataset <- merge(tumor_type, gene, by = 1)
dataset <- merge(tcga_pop, dataset, by = 1)

########## Data formatting ##########

# Calculation of the gene_x expression median
cutoff <- mean(as.numeric(dataset[, gene_x]), na.rm = TRUE)

# Add a column for a higher level than gene_x
cutted <- mutate(dataset, high = dataset[, gene_x] > cutoff)

# Remove the samples, study and the gene columns
cutted_melt <- subset(cutted, select = c(colnames(tcga_pop)[-seq(2)], "high"))

# Get a 3-column table with the value associated with each subtype and its level
sub_cutted_melt <- melt(cutted_melt)
colnames(sub_cutted_melt)[2] <- "cell_type"
sub_cutted_melt$value <- sub_cutted_melt$value + 1e-05

########## Plot ##########

# Plot the cell subtypes according to the gene expression level
pop <- ggviolin(
    data = sub_cutted_melt,
    x = "high",
    y = "value",
    facet.by = "cell_type",
    outlier.shape = NA,
    color = "cell_type"
) +
    scale_x_discrete(
        name = paste(gene_x, "level"),
        labels = c(`FALSE` = "Low", `TRUE` = "High")
    ) +
    scale_y_log10()
pop <- ggpar(pop, legend = "none")

# Add corrected Wilcoxon tests
stat <- sub_cutted_melt %>%
    group_by(cell_type) %>%
    wilcox_test(value ~ high) %>%
    adjust_pvalue(method = "BH") %>%
    add_significance() %>%
    subset(p.adj < 0.1) %>%
    add_xy_position(x = "high")
pop + stat_pvalue_manual(stat, label = "p.adj.signif")
