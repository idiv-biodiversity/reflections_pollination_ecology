# /////////////////////////////////////////////////////////////////////////
# Helper function used to clean & prepare words and stems for regex wrapping, 
# e.g. in prepare_patterns_1() and prepare_patterns_2() helper functions.
# /////////////////////////////////////////////////////////////////////////


# Input:
#
# words - Character vector of words and/or stems
#
# Returns a character vector


clean_words <- function(words) {
  # Defensively transform to character vector
  words <- as.character(words)
  # Remove empty characters if any
  words <- words[!words == ""]
  # Translate to lower case
  words <- tolower(words)
  # Remove any leading and trailing whitespace 
  words <- trimws(words, which = "both")
  # Removes any duplicated words if any
  words <- sort(unique(words))
  
  return(words)
}


# Usage example:

# clean_words(c("test", " test", "test ")) # note the extra white spaces
# [1] "test"
