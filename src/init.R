library(twitteR)
library(tidytext)
library(purrr)
library(dplyr)
library(stringr)
library(tidyr)

source("secret_keys.R") # initializes consumer_key, consumer_secret, access_token, and access_secret
source("utils.R")

options(httr_oauth_cache = TRUE)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

load("lexicon.Rdata")

n <- 1000
language <- "en"
result_type <- "recent"


regex <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|\\.?@[A-Za-z0-9_]+|&amp;|&lt;|&gt;|RT|rt|https|t.co"

term <- "Donald Trump"

result <- searchTwitter(term, n, lang = language, resultType = result_type) %>%
  map_df(as.data.frame) %>% 
  tbl_df()


tweets <- result %>%
  mutate(text = str_replace_all(text, regex, "")) %>%
  unnest_tokens(output = word, input = text) %>% 
  filter(word %notin% stop_words$word)
  
tweets <- tweets %>%
  left_join(lexicon, by = c("word" = "word")) %>% 
  group_by(id) %>%
  summarize(summed_score = sum(sentiment, na.rm = T)) %>%
  mutate(sentiment = case_when(.$summed_score < 0 ~ "negative", 
                               .$summed_score == 0 ~ "neutral",
                               .$summed_score > 0 ~ "positive")) %>%
  group_by(sentiment) %>%
  summarize(count = n()) %>%
  mutate(percentage = count/sum(count))


