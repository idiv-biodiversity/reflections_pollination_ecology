# /////////////////////////////////////////////////////////////////////////
# Helper function to prepare regular expression patterns for word matching,
# with the purpose of deleting given stop-word for making figure 1 and 3.
#
# This function is designed to be used in combination with tm::removeWords() 
# like: tm_map(my_corpus, FUN = removeWords, prepare_patterns_2(...))
# where the pattern returned by prepare_patterns_2() will be further wrapped 
# with "\\b" within tm::removeWords() for marking edges of words.
# /////////////////////////////////////////////////////////////////////////


# Input:
# as_is		      - Character vector of words to be treated as is;
#                 Compound words like "gene flow" can also be used.
# starting_with	- Character vector of stems to which the regex operators 
#                "[A-z]*?" are added as suffix in order to match 
#                 all possible endings.
#                 e.g. "love[A-z]*?"  matches all words starting with love:
#                 loving, loves, lovely, lovebug, etc 
#
# Returns a character vector of words and stems with "[A-z]*?" suffix


prepare_patterns_2 <- function(as_is, starting_with) {
  # Clean & prepare words and stems for regex wrapping
  as_is <- clean_words(as_is)
  starting_with <- clean_words(starting_with)
  
  # Add "[A-z]*?" regex operators as suffix to starting_with stems.
  starting_with_pattern <- paste0(starting_with, "[A-z]*?")
  
  # Prepare results
  patterns <- c(as_is, starting_with_pattern)
  return(patterns)
}
