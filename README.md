
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

## Docker

###### Pull

    docker pull eucee/tcga-viz

###### (Local installation)

    docker build -t tcga-viz .

###### Run in command-line

    docker run --rm \
      -p 127.0.0.1:8787:8787 \
      -v $(pwd):/home/rstudio \
      -e ROOT=TRUE \
      -e DISABLE_AUTH=true \
      tcga-viz

## Example

###### Load two data sets

(with the same cancer type and TCGA sample identifiers)

``` r
library(tcgaViz)
library(ggpubr, quietly = TRUE)
data(tcga)
head(tcga$genes)
#>   sample                 A                B                 C                D
#> 2 TCGA.1  8.97116117877886 4.26292435266078 0.492107251193374 1.85751097276807
#> 3 TCGA.2  9.12563563324511 2.73392115719616  3.24038315331563 5.03499635728076
#> 4 TCGA.3 0.701268787961453 8.47947539994493  7.76274828705937 1.61729729501531
#> 5 TCGA.4  2.16840990586206 2.21364883705974  3.06037642993033 1.14250980783254
#> 6 TCGA.5  9.09195550484583 6.35310396784917   6.0954469977878 7.76918348390609
#> 7 TCGA.6  5.76683731516823 5.04617205588147 0.535580450668931 8.22196035413072
#>                  E
#> 2 6.08688574051484
#> 3 7.24961997009814
#> 4  1.3692767242901
#> 5 2.57149390410632
#> 6 7.47873045271263
#> 7 5.85510938894004
head(tcga$cells$Cibersort_ABS)
#>   sample study        X1        X2        X3        X4        X5
#> 1 TCGA.1  BRCA 0.1477789 0.1488009 0.1038226 0.2023672 0.1634447
#> 2 TCGA.2  BRCA 0.1792274 0.2159358 0.1804520 0.2234023 0.1422903
#> 3 TCGA.3  BRCA 0.1640474 0.1183449 0.2076342 0.1778389 0.2221061
#> 4 TCGA.4  BRCA 0.1274322 0.2468163 0.1290748 0.2120794 0.1788205
#> 5 TCGA.5  BRCA 0.1436745 0.2173027 0.1437432 0.2468838 0.1685714
#> 6 TCGA.6  BRCA 0.1658555 0.1802094 0.1786337 0.1847483 0.1669041
```

###### Violin plot of cell subtypes

(and significance of a Wilcoxon adjusted test according to the
expression level \[high or low\] of a selected gene)

``` r
df <- (convert2biodata(
  algorithm = "Cibersort_ABS",
  disease = "breast invasive carcinoma",
  tissue = "Primary Tumor",
  gene_x = "A"
))
stats <- calculate_pvalue(df)
plot_violin(df, stats = stats)
```

<img src="man/figures/README-plot-1.png" width="100%" />
