#! /usr/bin/Rscript --vanilla
'Checkout git repo state from a certain date

Usage:
  git-time-travel [--date=DATE|-d DATE] [<repos>...]

if <repos> is not provided, the current directory is used

Options:
  -d --date=DATE    Date


The following formats are valid for DATE:
    "%Y-%m-%d %H:%M:%OS"
    "%Y/%m/%d %H:%M:%OS"
    "%Y-%m-%d %H:%M"
    "%Y/%m/%d %H:%M"
    "%Y-%m-%d"
    "%Y/%m/%d"

' -> doc


# opt <- docopt::docopt(doc, args = c("-d", "2020-01-01"))
# opt <- docopt::docopt(doc, args = c("--date=2020-01-01"))
# opt <- docopt::docopt(doc, args = c())
# opt <- docopt::docopt(doc, args = c("-h"))

opt <- docopt::docopt(doc)


library(cli)
library(fs)
library(git2r, warn.conflicts = FALSE)

opt$date <- if(!is.null(opt$date)) as.POSIXct(opt$date)

if(!length(opt$repos))
  opt$repos <- "."

# get terminal width for nicer printing
getCols <- function() {
  cols <- Sys.getenv("COLUMNS")
  if (nzchar(cols)) return(cols)

  cols <- tryCatch(
    strsplit(system('stty size 2>/dev/null', intern = TRUE), ' ')[[1]][2],
    warning = function(w) "", error = function(e) "")
  if (nzchar(cols)) return(cols)

  cols <- tryCatch(
    system("tput cols 2>/dev/null", intern = TRUE),
    warning = function(w) "", error = function(e) "")
  if (nzchar(cols)) return(cols)

  ""
  # https://stackoverflow.com/questions/1172485/how-to-increase-the-number-of-columns-using-r-in-linux
}

if (nzchar(cols <- getCols()))
  options(width = as.integer(cols))



git_time_travel <- function(repo_dir, verbose = FALSE) {
  repo <- repository(repo_dir)
  checkout(repo, "master")

  if(is.null(opt$date)) {
    cli_alert_info(sprintf("Checked out master branch of repo: '%s'",
                           repo_dir))
    return(invisible())
  }

  cmts <- as.data.frame(repo)
  cmts$email <- NULL   # not that useful for printouts
  cmts$message <- NULL # not that useful for printouts
  # if(is.unsorted(cmts$when))
  cmts <- cmts[order(cmts$when, decreasing = TRUE),]



  n_rollback <- which.min(cmts$when >= as.POSIXct(opt$date))

  if (verbose) {
    rollback <- tibble::as_tibble(cmts[seq_len(n_rollback - 1), ])
    if (nrow(rollback) > 0) {
      cli_alert(sprintf("Checking out repo %s before these commits:\n", repo_dir))
      print(rollback, n = 200)
    } else
      cli_alert("No commits to travel behind")
  }

  target <- lookup(repo, cmts$sha[n_rollback])
  if(verbose) {
    cli_alert_info("Checking out this commit:\n\t")
    print(target)
  }

  checkout(target)
}


# for(repo_dir in dir_ls("~/neid/ee-core", type = "directory")) {
for(repo_dir in opt$repos) {
  cat_rule()
  if (!is_dir(repo_dir)) {
    cli_alert_warning(sprintf("Skipping '%s' because not a directory", repo_dir))
    next
  }

  tryCatch(

    git_time_travel(repo_dir, verbose = TRUE),

    error = function(e) {
      cli_alert_danger(sprintf("Git checkout failed in dir '%s'", repo_dir))
      print(e)
    }
  )

  cat_rule()
}

invisible()
