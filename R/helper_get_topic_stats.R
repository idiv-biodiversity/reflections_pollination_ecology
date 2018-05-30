# /////////////////////////////////////////////////////////////////////////
# Helper function to compute the percent of articles that contain given words 
# at least one time in the title, abstract or keywords for each year.
# It also fits linear models to detect trends of article frequencies across time.
# /////////////////////////////////////////////////////////////////////////


# Input:
#
# words - data.table of topics to be followed across time;
#         First column contains the topic name, followed by columns 
#         containing words associated with each topic.
#         For catching all endings of a word, regular expression patterns will be used.
# text  - two columns data.table where each row represents an article;
#         column 'text' needs to contain all text to analyze for an article;
#         column 'PY' represents the publication year.
#         A row is an article.
#
# Returns a list of two tables. 
# One with topic frequencies and one with slope statistics.


get_topic_stats <- function(words, text){
  # Create empty list (will contain a list of data.tables, one for each topic)
  lst_dt <- vector(mode = "list", length = nrow(words))
  # For each topic in words, group text by year and do the followings:
  for (i in 1:nrow(words)){
    regex_patterns <- prepare_patterns_1(to_match = words[i, -"topic"])
    tbl <- text[, .(N_articles = .N, # count total number of articles (rows);
                    # count how many articles contain the given topic;
                    # use perl = TRUE for speed gain (results are identical with perl = FALSE)
                    N_articles_containing = sum(grepl(pattern = regex_patterns, 
                                                      x = text,
                                                      ignore.case = TRUE,
                                                      perl = TRUE)), 
                    # create a column to indicate the topic
                    topic = words[i, topic]), 
                # group by PY (publication year)
                by = PY]
    tbl[, percent := N_articles_containing / N_articles * 100]
    lst_dt[[i]] <- tbl
  }
  
  # Create empty lists:
  # - for storing linear model (lm)
  lst_lm <- vector(mode = "list", length = nrow(words))
  # - for storing slopes statistics for each linear model
  lst_slopes <- vector(mode = "list", length = nrow(words))
  
  # For each topic run a linear model and extract slope statistics
  for (i in 1:length(lst_dt)){
    lst_lm[[i]] <- lm(percent ~ PY, data = lst_dt[[i]])
    lst_slopes[[i]] <- data.table(summary(lst_lm[[i]])$coefficients[2, , drop = FALSE])
  }
  
  # Bind list of data.table results:
  
  # a) for slopes table
  dt_slopes <- rbindlist(lst_slopes)
  # rename columns
  setnames(dt_slopes, c("Estimate", "Std_Error", "t_value", "p_value"))
  dt_slopes[, topic := words$topic]
  
  # b) for yearly frequencies table
  dt_freq <- rbindlist(lst_dt)
  # Order/sort by topic and then by year
  setorder(dt_freq, topic, PY)
  
  # Prepare results
  results <- list(dt_freq, dt_slopes)
  names(results) <- c("freq", "slopes")
  return(results)
}
