# Author: Etienne CAMENEN
# Date: 2021
# Contact: etienne.camenen@gmail.com

FROM rocker/shiny-verse

MAINTAINER Etienne CAMENEN (etienne.camenen@gmail.com)

ENV PKGS libxml2-dev libcurl4-openssl-dev libssl-dev liblapack-dev git cmake qpdf
ENV _R_CHECK_FORCE_SUGGESTS_ FALSE
ENV TOOL_NAME tcgaViz
ENV TOOL_VERSION 0.6.0

RUN apt-get update --allow-releaseinfo-change -qq && \
    apt-get install -y ${PKGS}
RUN R -e "devtools::install_github('ecamenen/"${TOOL_NAME}"', ref = '"${TOOL_VERSION}"')"
RUN apt-get purge -y git g++ && \
	apt-get autoremove --purge -y && \
	apt-get clean && \
	rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

EXPOSE 3838

CMD ["R", "-e", "tcgaViz::run_app(options = list(host = '0.0.0.0', port = 3838))"]