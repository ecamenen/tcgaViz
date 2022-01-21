# A visualization tool to depict proportions of immune cells in any tumor
# relative to the average expression of any gene (or signature).

########## Environment setting ##########

algorithm <- "Cibersort_ABS"
disease <- "breast invasive carcinoma"
gene_x <- "A"
gene_file <- "/tcga_genes.tsv"
cell_file <- "/cell_pop.xlsx"
phenotype_file <- "/tcga_phenotypes.tsv"
path <- file.path("inst", "extdata")

########## Dataset loading ##########

# Import the phenotypes file
tcga_pop <- read.xlsx(paste0(path, cell_file), sheet = algorithm)

# Import the tumor type file
tumor_type <- read_delim(paste0(path, phenotype_file), show_col_types = FALSE)
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
gene <- read_delim(paste0(path, gene_file), show_col_types = FALSE)
gene <- transpose(gene, keep.names = "col", make.names = "sample")

# Merge datasets
dataset <- merge(tumor_type, gene, by = 1)

# Data formatting
sub_cutted_melt <- convert_biodata(dataset, tcga_pop, gene_x)

# Plot the cell subtypes according to the gene expression level
p <- plot_violin(sub_cutted_melt, gene_x)

# Add corrected Wilcoxon tests
stat <- calculate_pvalue(sub_cutted_melt)
p + stat_pvalue_manual(stat, label = "p.adj.signif")
