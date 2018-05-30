# /////////////////////////////////////////////////////////////////////////
# Script for figure 3: a network of bigrams 
# /////////////////////////////////////////////////////////////////////////


# If not yet done, run the script `R/01_packages.R` 
# to load (or install) the needed packages.

# cleans global environment
rm(list = ls())


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Read & process text data ------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# The text data to be analyzed is represented by the file /data/fig_3_text.txt
# and is a subset of /data/fig_2_text.csv
# It contains records from 2015 through 2017. The data includes the abstracts
# and titles for those years. SP pre-processed this file in Excel, 
# removing words like:
# "copyright", "Elsevier", "rights reversed", "rights" 
# (in context of publishing rights).

# Create volatile corpus from txt file
corpus <- VCorpus(x = DirSource(directory = "data/",
                                pattern   = "fig_3_text", 
                                encoding  = "UTF-8"))

# Call and run text processing script.
# This can take between few seconds and few minutes.
system.time( source("R/text_processing.R") )
# 35 sec on an Intel Core i5-4210U 1.7 GHz CPU


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prepare bigrams ---------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Tokenizing by bigrams
bigrams_tbl <- 
  data_frame(text = corpus[[1]][[1]]) %>% 
  tidytext::unnest_tokens(output = bigram, 
                          input = text, 
                          token = "ngrams", 
                          n = 2, 
                          to_lower = FALSE)

# Split bigrams in the two component words
bigrams_separated_tbl <- 
  bigrams_tbl %>%
  tidyr::separate(col = bigram, 
                  into = c("word1", "word2"), 
                  sep = " ")

# Count bigrams
bigram_count_tbl <- 
  bigrams_separated_tbl %>% 
  count(word1, word2, sort = TRUE)

# Create an igraph object from bigrams table.
# Keep only bigrams with more than 20 occurrences.
bigram_graph <- 
  bigram_count_tbl %>%
  filter(n >= 20) %>%
  igraph::graph_from_data_frame()


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prepare aesthetics data -------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Prepare aesthetics based on single word counts.

# ... get word counts -----------------------------------------------------

word_counts_tbl <- 
  data_frame(text = corpus[[1]][[1]]) %>% 
  tidytext::unnest_tokens(output = word, 
                          input = text, 
                          token = "ngrams", 
                          n = 1, 
                          to_lower = FALSE) %>% 
  count(word) %>% 
  arrange(desc(n))

# Note that, the vector names(bigram_graph[[]]) represents all the words 
# plotted as bubbles with the ggraph() function exactly in this order. 
# So any coloring and sizing of word bubbles can be indexed according to this vector.
# Below is a data.frame that will contain some helper columns for 
# grouping and coloring by frequency classes.

# This data frame connects the word frequencies computed above 
# with the words that are displayed in the graph:
aes_df <- merge(x = data.frame(word = names(bigram_graph[[]])),
                y = word_counts_tbl,
                by = "word",
                sort = FALSE) 
# sort = FALSE, so the order corresponds to the one in the graph


# ... word counts classes/intervals ---------------------------------------

# The distribution of word counts is skewed.
# Apply a univariate class intervals technique to get an idea about 
# how to split word counts in classes.
hist(aes_df$n, breaks = 100) 
summary(aes_df$n)

# Choose univariate class intervals. 
n_intervals <- 4
cls <- classInt::classIntervals(var = aes_df$n,
                                n = n_intervals,
                                style = "jenks")
cls # this gives an idea about the interval limits
# [22,286]   (286,764]  (764,1544] (1544,3902] 
#     103          42          12           4 
# View classes along "Empirical distribution function"
plot(cls, pal = c("wheat1", "red3"))

# Round the interval limits so that they are easy to read in the legend
cls_breaks <- c(floor(cls$brks[1]/10)*10, ceiling(cls$brks[-1]/100)*100)
cls$brks
# [1]   22  286  764 1544 3902
cls_breaks
# [1]   20  300  800 1600 4000

# Define a column for the frequency interval corresponding to each word
aes_df$interval <- cut(aes_df$n, 
                       breaks = cls_breaks,
                       dig.lab = n_intervals,
                       include.lowest = TRUE)
# Note that aes_df$interval is a factor
class(aes_df$interval)


# ... prepare tbl_graph object --------------------------------------------

# Convert igraph to tbl_graph object and add columns that will act as aesthetics
bigram_graph_tidy <- 
  tidygraph::as_tbl_graph(bigram_graph) %>% 
  mutate(interval = aes_df$interval,
         size = as.integer(aes_df$interval))
# Inspect the tbl_graph object
bigram_graph_tidy


# ... pick colors ---------------------------------------------------------

# Experimenting with colors for each class (interval)
col <- rev(RColorBrewer::brewer.pal(n = n_intervals, name = "RdYlBu"))
names(col) <- levels(aes_df$interval)

# Optional - show colours in a plot
scales::show_col(col)
# Add the interval labels to the plot
lbs <- matrix(names(col), ncol = ceiling(sqrt(length(col))), byrow = TRUE)
text(col(lbs) - 0.5, -row(lbs) + 0.35, lbs) 


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plot network ------------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Visualize the network of bigrams with ggraph()

set.seed(2018)

network_plot <- 
  ggraph(bigram_graph_tidy, layout = "nicely") +
  geom_edge_link(aes(edge_alpha = n),
                 show.legend = FALSE) +
  geom_node_point(aes(color = interval,
                      size = size),
                  alpha = .7) +
  scale_color_manual(name = "Frequency",
                     values = col) +
  scale_size_continuous(name = "Frequency",
                        labels = names(col)) +
  geom_node_text(aes(label = name),
                 nudge_x = 0.2,
                 nudge_y = 0.2,
                 size = aes_df$n^(1/7)+0.25) +
  theme_void() +
  theme(
    # Grab upper-right legend corner (x=1, y=1)
    legend.justification = c(1, 1),
    # and position it in the upper-right plot area.
    legend.position = c(0.97, 0.97),
    legend.margin = margin(t = 0, r = 0, b = 0, l = 0),
    # Set margin around entire plot.
    plot.margin = unit(c(t = -0.5, r = -0.2, b = -0.5, l = -0.5), "cm")
  )

# Save plot to PDF
ggsave(filename = "output/fig_3/fig_3_bigrame_network.pdf",
       plot = network_plot,
       width = 21, 
       height = 21, 
       units = "cm")

# The graph was further processed with Inkscape https://inkscape.org/en/


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Check bigram counts -----------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Check the counts of all bigram combinations of given words.
# E.g. for "gene", "flow"

setDT(bigram_count_tbl)

word_gr <- c("gene", "flow")
dt <- bigram_count_tbl[word1 %in% word_gr | word2 %in% word_gr]
dt

#        word1 word2   n
# 1:      gene  flow 129
# 2:    pollen  gene  17
# 3:    pollen  flow  13
# 4: transgene  flow  11
# 5:      flow  rate   8
# ---  
