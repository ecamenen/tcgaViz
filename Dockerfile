# Author: Etienne CAMENEN
# Date: 2021
# Contact: etienne.camenen@gmail.com

FROM rocker/rstudio

MAINTAINER Etienne CAMENEN (etienne.camenen@gmail.com)

ENV PKGS libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git cmake qpdf
ENV RPKGS attachment BiocManager config covr data.table devtools dplyr DT globals ggplot2 ggpubr golem knitr lintr openxlsx plotly readr reactlog reshape2 rmarkdown rstatix shinytest spelling testthat shiny styler
ENV _R_CHECK_FORCE_SUGGESTS_ FALSE

RUN apt-get update -qq && \
    apt-get install -y ${PKGS}
RUN Rscript -e 'install.packages(commandArgs(TRUE))' ${RPKGS}
RUN Rscript -e 'BiocManager::install("BiocCheck")'
RUN cd /home/rstudio/ && \
    Rscript -e 'shinytest::installDependencies()'
RUN apt-get install -y --no-install-recommends libxt6
COPY . /home/rstudio