# Author: Etienne CAMENEN
# Date: 2021
# Contact: etienne.camenen@gmail.com

FROM rocker/rstudio

MAINTAINER Etienne CAMENEN (etienne.camenen@gmail.com)

ENV PKGS libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git cmake qpdf
ENV RPKGS data.table dplyr ggplot2 ggpubr openxlsx readr reshape2 rstatix ggpubr rstatix BiocManager knitr rmarkdown spelling testthat covr devtools styler
ENV _R_CHECK_FORCE_SUGGESTS_ FALSE

RUN apt-get update -qq && \
    apt-get install -y ${PKGS}
RUN Rscript -e 'install.packages(commandArgs(TRUE),repos = "http://cran.us.r-project.org")' ${RPKGS}
RUN Rscript -e 'BiocManager::install("BiocCheck")'
COPY . /home/rstudio