source("secret_keys.R")

library(twitteR)
library(tidytext)
library(purrr)
library(dplyr)
library(stringr)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

term <- "barack obama"
result <- searchTwitter(term, 1000, lang = "en", resultType = "recent")
regex <- "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|\\.?@[A-Za-z0-9_]+|&amp;|&lt;|&gt;|RT|rt|https|t.co"
nrc <- get_sentiments("nrc")
bing <- get_sentiments("bing")
afinn <- get_sentiments("afinn")
tweets <-  result %>%
  map_df(as.data.frame) %>% 
  tbl_df() %>%
  mutate(text = str_replace_all(text, regex, "")) %>%
  mutate(text = str_replace_all(text, coll(term, ignore_case = T), "")) %>%
  unnest_tokens(output = token, input = text) %>% 
  dplyr::filter(!token %in% stop_words$word) %>% 
  left_join(bing, by = c("token" = "word")) %>% 
  group_by(sentiment) %>%
  summarize(count = n()) %>%
  filter(!is.na(sentiment)) %>%
  mutate(percentage = count/sum(count))


