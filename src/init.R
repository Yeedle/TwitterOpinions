source("secret_keys.R")

library(twitteR)
library(tidytext)
library(purrr)
library(dplyr)
library(stringr)

options(httr_oauth_cache = TRUE) 
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

nrc <- get_sentiments("nrc")
bing <- get_sentiments("bing")
afinn <- get_sentiments("afinn")


n <- 1000
language <- "en"
result_type <- "recent"

term <- "hitler"

result <- searchTwitter(term, n, lang = language, resultType = result_type) %>%
  map_df(as.data.frame) %>% 
  tbl_df()

regex <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|\\.?@[A-Za-z0-9_]+|&amp;|&lt;|&gt;|RT|rt|https|t.co"

tweets <-  result %>%
  mutate(text = str_replace_all(text, regex, "")) %>%
  mutate(text = str_replace_all(text, coll(term, ignore_case = T), "")) %>%
  unnest_tokens(output = token, input = text) %>% 
  filter(!token %in% stop_words$word)
  
tweets <- tweets %>%
  left_join(afinn, by = c("token" = "word")) %>% 
  group_by(id) %>%
  summarize(summed_score = sum(score,na.rm = T)) %>%
  mutate(sentiment = if_else(summed_score < 0, "negative", if_else(summed_score == 0, "neutral", "positive"))) %>%
  group_by(sentiment) %>%
  summarize(count = n()) %>%
  mutate(percentage = count/sum(count))


