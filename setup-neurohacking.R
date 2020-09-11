#!/usr/bin/Rscript --vanilla

install.packages("R.oo") # Must be installed without pkgs attached in .Rprofile
install.packages("R.utils")
install.packages("neurobase")
install.packages("oro.nifti")
install.packages("oro.dicom")
install.packages("fslr")

system("sudo apt update")
system("sudo apt install tk-dev")

install.packages("AnalyzeFMRI")


