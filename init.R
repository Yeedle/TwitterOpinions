source(secret_keys.R)

library(twitteR)
library(tidytext)
library(tidyverse)

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

term <- " cupcakes "
result <- searchTwitter(term, 1000, lang = "en")
tweets <-  result %>%
  map_df(as.data.frame) %>% 
  tbl_df()
