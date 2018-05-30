# /////////////////////////////////////////////////////////////////////////
# Script to load or install the needed packages.
#
# In order to make this project more reproducible we made available 
# the list of used R packages and their version numbers.
# One can find this information in `/packages/packages.csv` file. 
# Also, the R session information was stored in `/packages//sessionInfo.txt` file.
#
# This will install or load any current version of the packages.
# For installing older versions of the packages, one of the following packages 
# could be helpful: versions, devtools, checkpoint
# /////////////////////////////////////////////////////////////////////////


.packages <- c("classInt",
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
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
# Load packages into session 
sapply(.packages, require, character.only = TRUE)

# The package "pluralize" was not yet on CARN at the time of developing our project.
# Therefore, we used the GitHub (version 0.1.0) 
if(!"pluralize" %in% installed.packages()) devtools::install_github("hrbrmstr/pluralize")
library(pluralize)
