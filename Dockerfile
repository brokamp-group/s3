FROM rocker/r-ver:4.0.3
# rocker/r-ver > 4.0 uses RSPM and ubuntu 20.04
# but we need to set this manually for renv so it overrides CRAN repo set in lockfile
# ENV CRAN_RSPM=https://packagemanager.rstudio.com/all/__linux__/focal/latest

WORKDIR /app

RUN R --quiet -e "install.packages('remotes')"
RUN R --quiet -e "remotes::install_github('geomarker-io/s3')"
RUN R --quiet -e "reticulate::install_miniconda()"
RUN R --quiet -e "reticulate::py_install('boto3')"

RUN R --quiet -e "install.packages('devtools')"
RUN R --quiet -e "install.packages('withr')"

WORKDIR /s3

ENTRYPOINT ["R"]
