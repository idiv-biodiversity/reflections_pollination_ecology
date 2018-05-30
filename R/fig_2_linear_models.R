# /////////////////////////////////////////////////////////////////////////
# Script for Figure 2: Topics of interest in Pollination Ecology.
# Linear regressions of percent use of selected topics through time.
# /////////////////////////////////////////////////////////////////////////


# If not yet done, run the script `R/01_packages.R` 
# to load (or install) the needed packages.

# cleans global environment
rm(list = ls())

# Load helper function
source("R/helper_get_topic_stats.R")
source("R/helper_clean_words.R")
source("R/helper_prepare_patterns_1.R")


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Read and prepare data ---------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Data (text to be processed - "data/fig_2_text.csv) represents a collection 
# of titles, abstracts and keywords of all articles in the field of 
# Pollination Ecology across the time period from 1998 to 2017.
# The words and word pairs corresponding to the selected topics 
# are listed in /data/fig_2_selected_topics.csv

# Read text to be processed
dt_txt <- fread("data/fig_2_text.csv")

# Some defensive tests:
# - are there rows where TI is NA?
dt_txt[is.na(TI), .N] # none
# - are there rows where PY is NA?
dt_txt[is.na(PY), .N] # none
# - are there duplicated records by TI?
sum(duplicated(dt_txt, by = "TI")) # none

# For each row, put TI, DE, ID, AB in one bucket of words.
# Creates a column "text" that will act as this bucket of words.
dt_txt[, text := paste(TI, DE, ID, AB)]
# Remove columns that are not needed anymore.
dt_txt[, c("TI", "DE", "ID", "AB") := NULL]


# Read words and word pairs corresponding to selected topics.
dt_topics <- fread("data/fig_2_selected_topics.csv")

# Rename columns. Will rename columns irrespective of their already given names.
# Is expected that the first column contains the labels for each topic.
# For further details, check the metadata file fig_2_selected_topics.md
setnames(dt_topics, c("topic", paste0("words_", 1:(ncol(dt_topics)-1))))
# There should be no rows with empty topics.
dt_topics[is.na(topic), .N] # none


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Topic stats -------------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Apply article frequency function
topic_stats <- get_topic_stats(words = dt_topics, 
                               text = copy(dt_txt))

dt_freq   <- topic_stats$freq
dt_slopes <- topic_stats$slopes

# Save article frequencies to CSV file
write.csv(dt_freq, 
          file = "output/fig_2/article_counts_percent_per_year.csv", 
          row.names = FALSE)

write.csv(dt_slopes, 
          file = "output/fig_2/article_percent_slopes.csv", 
          row.names = FALSE)

# Check some stats
dt_freq[topic == "Population" & PY %between% c(1998, 2000), mean(percent)] # 43.40659
dt_freq[topic == "Community" & PY %between% c(1998, 2000), mean(percent)]  # 18.60223
dt_freq[topic == "Ecosystem service" & PY %between% c(1998, 2000), mean(percent)] # 0.7450882

dt_freq[topic == "Population" & PY %between% c(2015, 2017), mean(percent)] # 34.58841
dt_freq[topic == "Community" & PY %between% c(2015, 2017), mean(percent)]  # 32.52302
dt_freq[topic == "Ecosystem service" & PY %between% c(2015, 2017), mean(percent)] # 10.54316

dt_freq[topic == "Fragmentation" & PY %in% c(1998, 2017)]
dt_freq[topic == "Pesticide" & PY %in% c(1998, 2017)]


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Make graph --------------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Prepare a data frame with text labels referring to slope statistics.
# This is helpful to plot text info in each panel of the graph.
slope_labels <- 
  data.frame(
    PY = 1998,    # Will display text at position equivalent to 1998 on OX and
    percent = 57, # percent 57 on OY.
    label = paste0("slope = ", round(dt_slopes$Estimate, 2),
                   " (p ",
                   ifelse(dt_slopes$p_value < 0.001, 
                          yes = "< 0.001", 
                          no = paste0("= ", round(dt_slopes$p_value, 3))),
                   ")"),
    topic = dt_slopes$topic
  )

# Multi-panel plot
freq_plot <- 
  ggplot(data = copy(dt_freq),
         aes(x = PY,
             y = percent)) +
  # add the points
  geom_point(shape = 21, size = 1) +
  # add trend lines with 95% confidence intervals (CI)
  # For CI interpretation see:
  # https://stackoverflow.com/questions/29554796/meaning-of-band-width-in-ggplot-geom-smooth-lm
  # https://stackoverflow.com/a/28329143/5193830
  geom_smooth(method = 'lm', level = 0.95, size = 0.5) +
  # display slope statistics
  geom_text(aes(x = PY, 
                y = percent, 
                label = label),
            size = 2.5,
            hjust = 0,
            color = "black",
            data = slope_labels) +
  # set axis labels
  labs(x = "Publication year", 
       y = "Percent of articles") +
  # set OY axis limits
  scale_y_continuous(limits = c(-5, 60)) +
  theme_bw() +
  # create multi-panel figure
  facet_wrap(~ topic, ncol = 3) +
  theme(
    # eliminate minor grids
    panel.grid.minor = element_blank(),
    # edit major grids
    panel.grid.major = element_line(size = 0.3, linetype = "dashed"), 
    # set font size for all text within the plot
    # note that this can be overridden with other adjustment functions below
    text = element_text(size = 8),
    # adjust text in X-axis title
    axis.title.x = element_text(size = 8, face = "bold"),
    # adjust text in Y-axis title
    axis.title.y = element_text(size = 8, face = "bold"),
    # edit strip text and size for each panel
    # https://stackoverflow.com/questions/41428344/edit-strip-size-ggplot2
    strip.text.x = element_text(size = 8, 
                                face = "bold",
                                margin = margin(t = 0.1, 
                                                r = 0, 
                                                b = 0.1, 
                                                l = 0, 
                                                unit = "cm"))
  )

# Save plot to PDF
ggsave(filename = "output/fig_2/fig_2_lm.pdf",
       plot = freq_plot,
       width = 18,
       height = 21,
       units = "cm")
