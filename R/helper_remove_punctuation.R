# /////////////////////////////////////////////////////////////////////////
# Function to remove punctuation characters.
#
# This function is an adaptation of the `tm::removePunctuation()` function.
# It removes punctuation with inserting white spaces, whereas 
# `tm::removePunctuation()` does not insert them.
# See original code of `tm::removePunctuation()` at:
# https://rdrr.io/cran/tm/src/R/transform.R#sym-removeNumbers
#
# "We could use the removePunctuation() function to remove period characters. 
# However, this function simply removes punctuation without inserting white spaces.
# In case of formatting errors of the text this might accidentally join two words"
# from: Munzert, S., Rubba, C., Meiﬂner, P., & Nyhuis, D. (2014). 
# Automated data collection with R: A practical guide to web scraping and text mining. 
# John Wiley & Sons.
#
# Example:
# removePunctuation(x = "word1,word2")  # gives "word1word2" instead of "word1 word2" 
# remove_punctuation(x = "word1,word2") # gives "word1 word2"
#
# Note that, punctuation characters, as represented by the regular expression 
# character-class "[[:punct:]]", means:
# ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
# from: http://www.astrostatistics.psu.edu/su07/R/html/base/html/regex.html
# /////////////////////////////////////////////////////////////////////////


remove_punctuation <- function(x, preserve_intra_word_dashes = FALSE) {
    if (!preserve_intra_word_dashes)
      gsub("[[:punct:]]+", " ", x)
    else {
      # Assume there are no ASCII 1 characters.
      x <- gsub("(\\w)-(\\w)", "\\1\1\\2", x)
      x <- gsub("[[:punct:]]+", " ", x)
      gsub("\1", "-", x, fixed = TRUE)
    }
  }
