# /////////////////////////////////////////////////////////////////////////
# Text processing script used for making figure 1 and 3 
# (fig 1 - comparison word cloud and fig 3 - network).
# There is no special need to run this script because is called at run-time
# from the scripts making figure 1 and 3.
#
# The text processing steps involve:
# - transformations and cleaning
# - remove stop words and given words
# - singularize words
# - group words
# /////////////////////////////////////////////////////////////////////////


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load helper functions ---------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

source("R/helper_remove_punctuation.R")
source("R/helper_clean_words.R")
source("R/helper_prepare_patterns_2.R")

# Optional - take a copy of the raw corpus for later inspection
# corpus_raw <- corpus


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Text transformation & cleaning ------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Remove punctuation with inserting white spaces
corpus <- tm_map(corpus, content_transformer(remove_punctuation))

# Remove numbers with inserting white spaces
remove_numbers <- content_transformer(function(x) gsub("[[:digit:]]+", " ", x))
corpus <- tm_map(corpus, remove_numbers)

# Translate text to lower case
corpus <- tm_map(corpus, content_transformer(tolower))

rm(remove_punctuation, remove_numbers)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Remove words ------------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Remove English common stopwords. Use tidytext::stop_words$word 
# because it covers more cases than tm::stopwords("english") 
corpus <- tm_map(corpus, removeWords, tidytext::stop_words$word)


# Remove given words

# Read words from csv file
dt_stop_words <- fread("data/stop_words.csv")

# Prepare regular expression pattern from given words.
# To given stems, the regex operators "[A-z]*?" are added as suffix 
# in order to match all possible endings.
stopwords_pattern <- 
  prepare_patterns_2(as_is = dt_stop_words$stopwords_as_is,
                     starting_with = dt_stop_words$stopwords_starting_with)

# Delete (replace with space) the matched words based on the pattern
corpus <- tm_map(corpus, FUN = removeWords, stopwords_pattern)

# Eliminate extra whitespace 
corpus <- tm_map(corpus, stripWhitespace)

# Optional - compare a slice of the processed corpus with the raw corpus 
# to get an idea about the edits:
# corpus[[1]]$content[3]
# corpus_raw[[1]]$content[3]

rm(dt_stop_words, prepare_patterns_2, stopwords_pattern)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Singularize -------------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Singularization rules should be implemented if the singularization algorithm 
# does not do a proper job. However, most of the words will not end up 
# in the word cloud (only 200 words actually), so only one case of 
# singularization rule was needed.

# Get a table of all words and apply the singularization on each of them:
words <- as.data.table(as.matrix(TermDocumentMatrix(corpus)), 
                       keep.rownames = "words")
add_singular_rule(plural_word = "apis", singular_word = "apis")
words[, words_singular := pluralize::singularize(words)]
# Select only those words where the singular form differs from the original.
# Those are the cases where the original (e.g. plurals) should be replaced 
# with their singular form.
words2singularize <- words[words != words_singular, .(words, words_singular)]

# Replace the plurals with their singular form.
for(i in 1:nrow(words2singularize)){
  corpus <- tm_map(corpus, 
                   FUN = content_transformer(gsub), 
                   # wrap with \\b (means edge of word) and the (*UCP) regex verb
                   # lets the regex engine know to deal with Unicode
                   pattern = sprintf("(*UCP)\\b(%s)\\b", words2singularize[i, words]),
                   replacement = words2singularize[i, words_singular],
                   perl = TRUE)
} 
# Inspired from https://rdrr.io/cran/tm/src/R/transform.R#sym-removeWords

rm(words, words2singularize, i); gc()


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Word grouping -----------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# We avoided text stemming because it can profoundly alter words and proceeded 
# with grouping certain words that were considered as belonging together.

dt_group_words <- fread("data/group_words.csv", header = FALSE)

# Defensively remove any row with empty first word 
col_1 <- colnames(dt_group_words)[1]
dt_group_words <- dt_group_words[!( is.na(get(col_1)) | get(col_1) == "" )]

# Replace certain words with their group label.
for(i in 1:nrow(dt_group_words)){
  # clean possible artefacts
  words_to_match <- clean_words(dt_group_words[i, ])
  # prepare pattern for regex engine
  words_to_match <- paste(words_to_match, collapse = "|")
  corpus <- tm_map(corpus, 
                   FUN = content_transformer(gsub),
                   pattern = sprintf("(*UCP)\\b(%s)\\b", words_to_match),
                   replacement = dt_group_words[i, 1], # the first word of the row
                   perl = TRUE)
} 

rm(dt_group_words, col_1, words_to_match, i, clean_words)
gc()
