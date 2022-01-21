
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tcgaViz

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/tcgaViz)](https://CRAN.R-project.org/package=tcgaViz)
[![R build
status](https://github.com/ecamenen/tcgaViz/workflows/R-CMD-check/badge.svg)](https://github.com/ecamenen/tcgaViz/actions)
[![Codecov test
coverage](https://codecov.io/gh/ecamenen/tcgaViz/branch/develop/graph/badge.svg)](https://codecov.io/gh/ecamenen/tcgaViz?branch=master)
<!-- badges: end -->

A visualization tool to depict proportions of immune cells in any tumor
relative to the average expression of any gene (or signature).

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ecamenen/tcgaViz")
```

## Example

#### Load two data sets

(with the same cancer type and TCGA sample identifiers)

``` r
library(tcgaViz)
library(ggpubr, quietly = TRUE)
data(tcga)
head(tcga$genes)
#>   sample                 A                B                C                D
#> 2 TCGA.1 0.264956243336201  7.5578053551726 6.64468276314437 7.30197078548372
#> 3 TCGA.2  5.80623494228348  4.3964810599573  0.2317652432248 4.25982138840482
#> 4 TCGA.3  1.51089240098372 5.28972591506317 4.53657245496288 4.55307093448937
#> 5 TCGA.4                 0                0                0                0
#> 6 TCGA.5                 0                0                0                0
#> 7 TCGA.6                 0                0                0                0
#>                  E
#> 2 7.20611368305981
#> 3 4.37935584923252
#> 4 2.05277875065804
#> 5                0
#> 6                0
#> 7                0
head(tcga$cells)
#>   sample study         X1         X2         X3          X4          X5
#> 1 TCGA.1  BRCA 0.11964897 0.17258556 0.22736153 0.162625148 0.157512098
#> 2 TCGA.2  BRCA 0.13435747 0.11526549 0.18884739 0.247721644 0.124613627
#> 3 TCGA.3  BRCA 0.19983883 0.17633938 0.10698929 0.222369858 0.189028837
#> 4 TCGA.4  BRCA 0.02814420 0.02120825 0.03030321 0.033897122 0.048205742
#> 5 TCGA.5  BRCA 0.03173877 0.02522355 0.04228744 0.008519522 0.040753161
#> 6 TCGA.6  BRCA 0.01788060 0.02112549 0.01904156 0.032661149 0.005202346
```

#### Violin plot of cell subtypes

(and significance of a Wilcoxon adjusted test according to the
expression level \[high or low\] of a selected gene)

``` r
df <- convert_biodata(tcga$genes, tcga$cells, select = "A")
p <- plot_violin(df, gene = "gene A")
stats <- calculate_pvalue(df)
p + stat_pvalue_manual(stats, label = "p.adj.signif")
```

<img src="man/figures/README-plot-1.png" width="100%" />
