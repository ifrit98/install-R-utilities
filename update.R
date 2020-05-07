#!/usr/bin/Rscript --vanilla

repos <- "https://cran.rstudio.com"


Sys.setenv("R_PROFILE_USER" = '')
Sys.setenv("R_ENVIRON_USER" = '')

Ncpus <- as.integer( .8 *
  as.integer(system("grep ^processor /proc/cpuinfo | wc -l", TRUE)))


options(Ncpus = Ncpus,
        repos = "http://cran.rstudio.org")



get_writable_libs <- function() vapply(.libPaths(),  function(lib)
  dir.exists(lib) && file.access(lib, mode = 2) == 0, TRUE)

is_writable <- get_writable_libs()

if(!any(is_writable)) {
  user_lib <- Sys.getenv("R_LIBS_USER")
  warning("*** Creating user library at ", user_lib, " ***")
  user_lib <- normalizePath(user_lib, mustWork = FALSE)
  if(!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
  .libPaths(c(user_lib, .libPaths()))
  is_writable <- get_writable_libs()
}


# --- update CRAN packages. ---
#
# for directories where we don't have write permissions, if the package is
# masked then ignore it otherwise install it in the first entry on the search
# path.

x <- lapply(.libPaths(), function(lib) {
  oldPkgs <- old.packages(lib, checkBuilt = TRUE)
  if(is.null(oldPkgs)) return(NULL)
  if (!is_writable[lib]) {
    is_not_masked <-
      vapply(rownames(oldPkgs),
             function(pkg) find.package(pkg) == file.path(lib, pkg), TRUE,
             USE.NAMES = FALSE)
    if(!any(is_not_masked)) # all false
      return(NULL)
    oldPkgs <- oldPkgs[is_not_masked,, drop = FALSE]
    oldPkgs[,"LibPath"] <- .libPaths()[1L]
  }
  oldPkgs[,c("Package", "LibPath")]
})


oldPkgs <- do.call(rbind, x)
oldPkgs <- unique(oldPkgs)



install.packages(oldPkgs[,"Package"], oldPkgs[,"LibPath"],
                 dependencies = FALSE,
                 INSTALL_opts = "--use-vanilla")


# withCallingHandlers(
#   do.call(update.packages, args),
#   warning = function(w) {
#     if (grepl(.Library, w$message, fixed = TRUE))
#       invokeRestart("muffleWarning")
#   }
# )
