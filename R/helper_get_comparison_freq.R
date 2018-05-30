# /////////////////////////////////////////////////////////////////////////
# Function to extract word frequencies as they would appear in a comparison word cloud.
# The code was adapted from https://github.com/ifellows/wordcloud ("wordcloud" package),
# the comparison.cloud() function.
# /////////////////////////////////////////////////////////////////////////

# Input:
#
# term.matrix - A term frequency matrix whose rows represent words and 
#               whose columns represent documents.
#
# Returns a four columns data frame. For each word the maximum relative frequency 
# is returned together with labels indicating to which document it belongs.


get_comparison_freq <- function(term_matrix){
  ndoc <- ncol(term_matrix)
  
  # Compute relative frequencies
  for(i in 1:ndoc){
    term_matrix[,i] <- term_matrix[,i] / sum(term_matrix[,i])
  }
  mean.rates <- rowMeans(term_matrix)
  for(i in 1:ndoc){
    term_matrix[,i] <- term_matrix[,i] - mean.rates
  }
  
  # Label each word with the group/document to which it belongs
  # based on maximum relative frequency
  group <- apply(term_matrix, 1, function(x) which.max(x))
  doc   <- colnames(term_matrix)[group]
  words <- rownames(term_matrix)
  # Maximum relative frequencies for each word
  freq  <- apply(term_matrix, 1, function(x) max(x))
  
  return(data.frame(words, freq, group, doc))
}
