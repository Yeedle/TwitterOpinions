library(httr)

emoticon_lexicon_url <- "http://saifmohammad.com/Lexicons/NRC-Hashtag-Emotion-Lexicon-v0.2.zip"


temp <- tempfile()
download.file(emoticon_lexicon_url, temp)
unzip(zipfile = temp, exdir = tempdir())
unlink(temp)

emoticon_zipfile <- GET(emoticon_lexicon_url)
unzip(zipfile = emoticon_zipfile$content)
