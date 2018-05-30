# /////////////////////////////////////////////////////////////////////////
# Helper function to prepare regular expression patterns for word matching,
# with the purpose of counting word occurences for making figure 2.
# It is called by get_topic_stats() helper function.
# /////////////////////////////////////////////////////////////////////////


# Input:
#
# to_match - character vector for regular expression wrapping
#
# Returns a regular expression pattern


prepare_patterns_1 <- function(to_match){
  # Clean & prepare words and/or stems for regex wrapping
  regex_patterns <- clean_words(to_match)
  
  # If a word (stem) ends with "*" symbol, then replace it with "[A-z]*?"
  # so that will match all possible endings.
  regex_patterns <- 
    ifelse(test = grepl(pattern = "\\*$", x = regex_patterns),
           yes = gsub(pattern = "\\*", replacement = "[A-z]*?", x = regex_patterns),
           no  = regex_patterns)
  
  # Prepare the final regular expression complex patterns
  regex_patterns <- paste0(regex_patterns, collapse = "|")
  # Wrap pattern with word boundaries \\b (https://stackoverflow.com/a/7227999/5193830)
  regex_patterns <- paste0("\\b(", regex_patterns, ")\\b")
  return(regex_patterns)
}

# Usage examples:

# prepare_patterns_1(to_match = c("climate chang*", "climate warm*", "test"))
# # "\\b(climate chang[A-z]*?|climate warm[A-z]*?|test)\\b"
# 
# prepare_patterns_1(to_match = c("community", "communities"))
# # "\\b(communities|community)\\b"
