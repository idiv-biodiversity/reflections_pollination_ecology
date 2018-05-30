# /////////////////////////////////////////////////////////////////////////
# Script for figure 1: Comparison word cloud.
# /////////////////////////////////////////////////////////////////////////

# If not yet done, run the script `R/01_packages.R` 
# to load (or install) the needed packages.

# cleans global environment
rm(list = ls())

# Load helper function
source("R/helper_get_comparison_freq.R")


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Read & process text data ------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The text data is represented by the two csv files 
# /data/fig_1_text_current.csv and fig_1_text_early.csv
# These two files are a subset of /data/fig_2_text.csv
# After subseting, SP pre-processed these files in Excel, 
# removing words like:
# "copyright", "Elsevier", "rights reversed", "rights" 
# (in context of publishing rights).

# Create volatile corpus from csv files
corpus <- VCorpus(x = DirSource(directory = "data/",
                                pattern   = "fig_1_",
                                encoding  = "UTF-8"))

# Call and run text processing script.
# This can take between few seconds and few minutes.
system.time( source("R/text_processing.R") )
# 35 sec on an Intel Core i5-4210U 1.7 GHz CPU


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Make word cloud ---------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Build a term-document matrix
tdm <- as.matrix(TermDocumentMatrix(corpus))

colnames(tdm) <- c("2015-2017", "1998-2000")

# Open pdf device
pdf(file = "output/fig_1/fig_1_comparison_cloud.pdf",
    width = 8/2.54, height = 8/2.54)
set.seed(1234)
comparison.cloud(term.matrix = tdm,
                 scale = c(2, .35),
                 max.words = 200, 
                 title.size = 1.1, 
                 rot.per = 0,
                 colors = c("#d95f02",  # current
                            "#7570b3")) # early
# Close pdf device
dev.off()

# Note that the words:
# incompatibility, deceptive, intensification could not be fit on page.

# The word cloud was further processed with Inkscape https://inkscape.org/en/


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Comparison frequencies --------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Select the top 200 words from the word cloud with their relative frequencies, 
# sort by frequency and save to csv file.

cloud_freq <- get_comparison_freq(tdm)
setDT(cloud_freq)
setorder(cloud_freq, -freq)
cloud_freq_subset <- cloud_freq[1:200]

write.csv(cloud_freq_subset, 
          file = "output/fig_1/cloud_freq.csv", 
          row.names = FALSE)
