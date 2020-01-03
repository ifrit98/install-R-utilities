#!/usr/bin/Rscript

system("sudo apt install libcurl4-openssl-dev libxml2-dev libssl-dev")

install.packages(c("curl", "xml2", "httr"))
install.packages("devtools")
install.packages(c("magrittr", "zeallot", "listarrays"))

devtools::install_github("rstudio/tensorflow")
devtools::install_github("rstudio/keras")
devtools::install_github("rstudio/reticulate")

install.packages("tidyverse")

