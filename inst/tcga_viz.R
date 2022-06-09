# A visualization tool to depict proportions of immune cells in any tumor
# relative to the average expression of any gene (or signature).

########## Environment setting ##########

algorithm <- "Cibersort_ABS"
disease <- "breast invasive carcinoma"
gene_x <- "ICOS"
tissue <- "Primary Tumor"
path <- system.file("extdata", package = "tcgaViz")

########## Dataset loading ##########
message("TCGA loading in progess...")
load(file.path(path, "tcga.rda"))

# Data formatting
df <- convert2biodata(algorithm, disease, tissue, gene_x, stat = "mean")

# Add corrected tests
stats <- calculate_pvalue(
    df,
    method_test = "wilcox_test",
    method_adjust = "BH",
    p_threshold = 0.05
)

# Plot the cell subtypes according to the gene expression level
plot(df, stats = stats, type = "violin", dots = FALSE)
