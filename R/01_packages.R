# /////////////////////////////////////////////////////////////////////////
# Script to load or install the needed packages.
#
# In order to make this project more reproducible we made available 
# the list of used R packages and their dependencies with their version numbers.
# One can find this information in "/packages/packages.csv" file. 
# Also, the R session information was stored in "/packages/sessionInfo.txt" file.
# If needed, check "packages/session_info.R" script to see how these files were created.
#
# Note that, this script (/R/01_packages.R) will load and/or install 
# any current version of the R packages.
#
# For installing older versions of the packages, one of the following packages 
# could be helpful: "versions", "devtools", "checkpoint".
# The "versions" package might be a more flexible options for Windows users because 
# it does not require Rtools https://cran.r-project.org/bin/windows/Rtools/
# This Stack Overflow discussion is also helpful: 
# https://stackoverflow.com/q/17082341/5193830
# 
# # Here is an example for installing the "MASS" package version" 7.3-47"
# install.packages('versions')
# library(versions)
# if(!dir.exists("packages/lib/")) dir.create("packages/lib/")
# install.versions(pkgs = "MASS", versions = "7.3-47", lib = "packages/lib/")
# # Do you want to install from sources the package which needs compilation?
# #   y/n: n
# /////////////////////////////////////////////////////////////////////////


packages <- c("classInt",
              "data.table",
              "devtools",
              "dplyr",
              "ggplot2",
              "ggraph",
              "igraph",
              "RColorBrewer",
              "scales",
              "tidygraph",
              "tidyr",
              "tidytext",
              "tm",
              "wordcloud")

# Install packages (if not already installed)
inst <- packages %in% installed.packages()
if(length(packages[!inst]) > 0) install.packages(packages[!inst])
# Load packages into session 
sapply(packages, require, character.only = TRUE)

# The package "pluralize" was not yet on CRAN at the time of developing our project.
# Therefore, we used the GitHub development version (pluralize, version 0.1.0).
# Note that the "devtools" package requires the installation of Rtools 
# https://cran.r-project.org/bin/windows/Rtools/ for Windows users.
if(!"pluralize" %in% installed.packages()) devtools::install_github("hrbrmstr/pluralize")
library(pluralize)
