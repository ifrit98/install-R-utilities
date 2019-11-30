#/usr/bin/Rscript --vanilla

## load docopt and remotes (or devtools) from CRAN
suppressMessages(library(docopt))
suppressMessages(library(remotes))

doc <-
"Usage: install.github.R [-h] [-d DEPS] [-f|--force] REPOS ...

-d --deps DEPS    Install suggested dependencies as well? [default: NA]
-h --help         show this help text
-f --force        force reinstall
"

repos <- "https://cran.rstudio.com"

lib.loc <- Sys.getenv("R_LIBS_USER")
if (lib.loc == "")
  lib.loc <- Sys.getenv("R_LIBS_SITE")

lib.loc <- if (lib.loc == "")
  .libPaths()[[1]] else
    strsplit(lib.loc, ":", fixed = TRUE)[[1]][[1]]

# docopt parsing
opt <- docopt(doc)
if (opt$deps == "TRUE" || opt$deps == "FALSE") {
  opt$deps <- as.logical(opt$deps)
} else if (opt$deps == "NA") {
  opt$deps <- NA
}

Ncpus <- as.integer(system("grep ^processor /proc/cpuinfo | wc -l", TRUE))
Ncpus <- as.integer(Ncpus * .8)

message("Installing packages into: \n  ", lib.loc)

for (repo in opt$REPOS)
  install_github(
    repo,
    dependencies = opt$deps,
    force = opt$force,
    Ncpus = Ncpus,
    lib = lib.loc,
    repos = repos,
    INSTALL_opts = "--use-vanilla"
  )

