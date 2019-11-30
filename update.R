#!/usr/bin/Rscript --vanilla

repos <- "https://cran.rstudio.com"

lib.loc <- Sys.getenv("R_LIBS_USER")
if(lib.loc == "")
  lib.loc <- Sys.getenv("R_LIBS_SITE")

lib.loc <- if (lib.loc == "")
  .libPaths()[[1]] else
  strsplit(lib.loc, ":", fixed = TRUE)[[1]][[1]]

Ncpus <- as.integer(
  as.integer(system("grep ^processor /proc/cpuinfo | wc -l", TRUE)) * .8)

ops <- options(warn = -1)

message(paste(sep = "\n",
  sprintf("Updating packages in:\n%s", paste("  ", .libPaths(), collapse = "\n")),
  sprintf("Newer version will be installed in: \n %s", lib.loc),
  sprintf("Using up to %i cores", Ncpus)))

withCallingHandlers(
  update.packages(
    instlib = lib.loc,
    repos = repos,
    checkBuilt = TRUE,
    Ncpus = Ncpus,
    ask = FALSE,
    INSTALL_opts = "--use-vanilla"
  ),
  warning = function(w) {
    if (grepl(.Library, w$message, fixed = TRUE))
      invokeRestart("muffleWarning")
  }
)
