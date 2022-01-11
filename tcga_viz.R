# a simple tool to depict proportions of immune cells in any tumors
#relative to the mean or median or quartiles of expression of any gene (or a signature?)

geneX <- "ICOS"

library(readxl)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(rstatix)
library(reshape2)

setwd("Documents/TCGA/")
#Import Cybersort dataset (to be modified for various algorithms: sheet)
#ideally one would want to be able to select which algorithms to use before import
TCGA_pop <- read_excel("TCGA.xlsx", sheet = "Cibersort_ABS")
#ideally one would want to be able to select tumor type before selecting the gene
Tumor_type <- read.delim ('TCGA_phenotype_denseDataOnlyDownload.tsv', check.names = F)
#Import gene dataset (to be modified: pathway)
Gene <- read.delim("EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena.txt")
Gene <- transpose(Gene, keep.names = "col", make.names = "sample")

#Merge datasets + remove sample with NA
Dataset <- merge(Tumor_type, Gene, by = 1)
Dataset <- merge(TCGA_pop, Dataset, by = 1)

#Calcul cuttedian of Gene + creation column > cutoff (ideally one would want to be able to filter on median
#and quartiles as well. Would be even better if one could enter a list of genes: the cut off would then be
#on the mean value for all genes listed)
cutoff <- mean(as.numeric(Dataset[, geneX]), na.rm = TRUE)
#number of patients in each category should be indicated in the figure

cutted <- mutate(Dataset,high=Dataset[, geneX]>cutoff)

#Plot sous type cell selon niveau d'expression du gène + stats
cutted_melt <- subset(cutted, select = c(colnames(TCGA_pop)[-seq(2)], "high"))
sub_cutted_melt  <- melt(cutted_melt)
colnames(sub_cutted_melt)[2] <- "cell_type"
sub_cutted_melt$value<-sub_cutted_melt$value+1e-5
pop <- ggviolin(sub_cutted_melt,x="high", y="value", facet.by = "cell_type", outlier.shape = NA,
                 color = "cell_type")+
  scale_x_discrete(name=paste(geneX, "level"), labels=c("FALSE"="Low","TRUE"="High")) +
  scale_y_log10()
pop  <- ggpar(pop, legend = 'none')

stat3 <- sub_cutted_melt%>%
  group_by(cell_type)%>%
  wilcox_test(value~high)%>%
  adjust_pvalue(method="BH")%>%
  add_significance() %>%
  subset(p.adj < 0.1)%>%
  add_xy_position(x="high")
pop <- pop + stat_pvalue_manual(stat3, label = "p.adj.signif")
pop

