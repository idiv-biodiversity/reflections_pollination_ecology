# Metadata

Here is stored the text data used to develop the figures from the manuscript along with the underlying text processing.

### Figure 1 - comparative word cloud

The text data for figure 1 is stored in `fig_1_text_current.csv` and `fig_1_text_early.csv` files.
These two files are a subset of `fig_2_text.csv` file. After subseting, SP pre-processed these files in Excel, removing words like: "copyright", "Elsevier", "rights reversed", "rights" (in context of publishing rights).


### Figure 2 - linear models

The text data for figure 2 is stored in `fig_2_text.csv` file and represents a collection of titles, abstracts and keywords of all articles in the field of Pollination Ecology across the time period from 1998 to 2017. This data was collected from the Web of Science in the summer of 2017.

|Column name |Meaning                                                     |
|:-----------|:-----------------------------------------------------------|
|TI	         | title |
|AB	         | abstract |
|PY	         | publication year |
|DE          | keywords the author(s) selected | 
|ID          | Keywords Plus - additional key words selected by Web of Science |

Check also [Web of Science Core Collection Field Tags](https://images.webofknowledge.com/images/help/WOS/hs_wos_fieldtags.html)


### Figure 3 - bigrame network

The text data for figure 3 is stored in `fig_3_text.txt` file and is a subset of `fig_2_text.csv`. It contains records from 2015 through 2017. The data includes the abstracts and titles for those years. SP pre-processed this file in Excel, removing words like: "copyright", "Elsevier", "rights reversed", "rights" (in context of publishing rights).


### Stop-words and group-words for figure 1 and 3

The stop-words and group-words used in figure 1 and 3 are stored in `stop_words.csv` and `group_words.csv` files.
They correspond to *Table S1.* from the manuscript's appendix.

Columns in `stop_words.csv` file:

|Column name             |Meaning                                         |
|:-----------------------|:-----------------------------------------------|
|stopwords_as_is         | Stop-words to be used as such |
|stopwords_starting_with | Word stems |

File `group_words.csv` does not have a header with column names. However, the first column contains the labels for each following word. 
Example - the first row contains the words (in this order): *"associate", "associated", "association", "associative"*, which will all be labeled/grouped as **"associate"**.


### Topics for figure 2

The words and word pairs corresponding to the selected topics for figure 2 are listed in `fig_2_selected_topics.csv` file.

|Column name |Meaning                                                     |
|:-----------|:-----------------------------------------------------------|
|TOPIC       | Selected topic |
|WORDS_x     | Words to be matched for each selected topic |
