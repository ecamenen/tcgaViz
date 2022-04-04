# A visualization tool to depict proportions of immune cells in any tumor
# relative to the average expression of any gene (or signature).

########## Environment setting ##########

algorithm <- "Cibersort_ABS"
disease <- "breast invasive carcinoma"
gene_x <- "ICOS"
tissue <- "Primary Tumor"
path <- file.path(golem::get_golem_wd(), "inst", "extdata")

########## Dataset loading ##########
load(file.path(path, "tcga_raw.rda"))
message("TCGA loading in progess...")

# Import the phenotypes file
tcga_pop <- tcga_raw$cells[[algorithm]]

# Import the tumor type file
diseases <- tcga_raw$phenotype
if (!is.null(disease)) {
    diseases <- diseases[
        diseases$`_primary_disease` == disease,
    ]
}

tumor_type <- diseases
if (!is.null(disease)) {
    tumor_type <- diseases[
        diseases$sample_type == tissue,
        "sample"
    ]
    if (nrow(tumor_type) == 0)
        stop("Selected tissue has 0 element.")
}

# Import the gene file
gene <- dplyr::select(
    tcga_raw$genes,
    col,
    all_of(gene_x)
)

# Merge datasets
dataset <- merge(tumor_type, gene, by = 1)

# Data formatting
sub_cutted_melt <- convert_biodata(dataset, tcga_pop, gene_x)

# Plot the cell subtypes according to the gene expression level
p <- plot_violin(sub_cutted_melt, gene_x)

# Add corrected Wilcoxon tests
stat <- calculate_pvalue(sub_cutted_melt)
p + ggpubr::stat_pvalue_manual(stat, label = "p.adj.signif")
