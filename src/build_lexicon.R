library(twitteR)
library(dplyr)

source("utils.R")

afinn <- get_sentiments("afinn")
nrc <- get_sentiments("nrc")
bing <- get_sentiments("bing")

augmented_afinn <- afinn %>% mutate(sentiment = 
                                      case_when(.$score < 0 ~ "negative",
                                                .$score > 0 ~ "positive"))
nrc_sentiments <- nrc %>% filter(sentiment %in% c("positive", "negative"))

disputes <- full_join(augmented_afinn, bing, by=c("word"="word")) %>% 
  full_join(nrc_sentiments, by=c("word"="word")) %>%
  filter(sentiment.x != sentiment.y | 
           sentiment.y != sentiment | 
           sentiment.x != sentiment) 

resolved_disputes <- disputes %>%
  mutate(afinn = case_when(.$sentiment.x == "positive" ~ 1,
                           .$sentiment.x == "negative" ~ -1),
         bing = case_when(.$sentiment.y == "positive" ~ 1,
                          .$sentiment.y == "negative" ~ -1),
         nrc = case_when(.$sentiment == "positive" ~ 1,
                         .$sentiment == "negative" ~ -1),
         consensus = afinn + bing + nrc) %>%
  filter(!is.na(consensus)) %>%
  mutate(sentiment = ifelse(consensus == 1, "positive", "negative")) %>%
  select(word, sentiment)

lexicon <- full_join(augmented_afinn, bing, by = c("word", "sentiment")) %>% 
  full_join(nrc_sentiments, by = c("word", "sentiment")) %>%
  select(word, sentiment) %>% 
  filter(word %notin% disputes$word) %>%
  full_join(resolved_disputes, by = c("word", "sentiment")) %>%
  mutate(sentiment = ifelse(sentiment == "positive", 1 , -1))

save(lexicon, file="lexicon.Rdata")

rm(list = ls())

