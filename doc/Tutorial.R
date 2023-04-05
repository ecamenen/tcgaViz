## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----data---------------------------------------------------------------------
library(tcgaViz)
library(ggplot2)
data(tcga)
head(tcga$genes)
head(tcga$cells$Cibersort_ABS)

## ----plot, warning = FALSE----------------------------------------------------
df <- convert2biodata(
  algorithm = "Cibersort_ABS",
  disease = "breast invasive carcinoma",
  tissue = "Primary Tumor",
  gene_x = "ICOS"
)
(stats <- calculate_pvalue(df))
plot(df, stats = stats)

## ----advanced-----------------------------------------------------------------
(df <- convert2biodata(
  algorithm = "Cibersort_ABS",
  disease = "breast invasive carcinoma",
  tissue = "Primary Tumor",
  gene_x = "ICOS",
  stat = "quantile"
))
(stats <- calculate_pvalue(
  df,
  method_test = "t_test",
  method_adjust = "bonferroni",
  p_threshold = 0.01
))
plot(
  df,
  stats = stats,
  type = "boxplot",
  dots = TRUE,
  xlab = "Expression level of the 'ICOS' gene by cell type",
  ylab = "Percent of relative abundance\n(from the Cibersort_ABS algorithm)",
  title = toupper("Differential analysis of immune cell type abundance
    based on RNASeq gene-level expression from The Cancer Genome Atlas"),
  axis.text.y = element_text(size = 8, hjust = 0.5),
  plot.title =  element_text(face = "bold", hjust = 0.5),
  plot.subtitle =  element_text(size = , face = "italic", hjust = 0.5),
  draw = FALSE
) + labs(
  subtitle = paste("Breast Invasive Carcinoma (BRCA; Primary Tumor):",
                   "Student's t-test with Bonferroni (P < 0.01)")
)

## ----end, echo = FALSE--------------------------------------------------------
sessionInfo()

