README
================

In this project I will apply some text (NLP ) analyses on all the transcripts from security now (SN) episodes.

SN is a highly informative podcast by Steve Gibson and Leo Laporte about security related news and or explanations of concepts. The series is long running for almost 13 years at the time of writing.

Steve has someone transcribe all of the audio files, that means we can use NLP tools to analyze all of the text.

I've only listened to the last few years.

example of top of [file](https://www.grc.com/sn/sn-020.txt):

    GIBSON RESEARCH CORPORATION http://www.GRC.com/

    SERIES:     Security Now!
    EPISODE:        #20
    DATE:       December 29, 2005
    TITLE:      A SERIOUS new Windows vulnerability - and Listener Q&A #2
    SPEAKERS:   Steve Gibson & Leo Laporte
    SOURCE FILE:    http://media.GRC.com/sn/SN-020.mp3
    FILE ARCHIVE:   http://www.GRC.com/securitynow.htm
        
    DESCRIPTION:  On December 28th a serious new Windows vulnerability appeared and was immediately exploited by a growing number of malicious web sites to install malware.  Many worse viruses and worms are expected soon.  We start off discussing this, and our show notes provide a quick necessary workaround until Microsoft provides a patch.  Then we spend the next 45 minutes answering and discussing interesting listener questions.

    LEO LAPORTE:  This is Security Now! with Steve Gibson, Episode 20, for December 29, 2005.

    STEVE GIBSON:  Last episode of this year.

    LEO:  The last episode of 2005.  And we've done 20 of them.

    STEVE:  Yeah.

As you can see this text is very structured

This project has two parts:

-   build a scraper that downloads/ reads in all of the text
    -   iterate through all of the links
    -   extract the metadata on top of the file (Date, Title, speakers, sourcefile, Description)
    -   a row per sentence
-   build cool stuff on top of this file
    -   classifier that predicts who speaks?\*
    -   sentiment analyses per episode, per season
    -   bot that talks like Steve and Leo\*
    -   topic model or word2vec\*
    -   network analysis of words

``` r
suppressPackageStartupMessages(library(tidyverse))
library(tidytext)
df_sn <- read_rds("df_sn.RDS")
```

unnest into paragraph per line.

``` r
test <- df_sn %>% tail(15) %>% tidyr::unnest(text) %>% mutate(speaker = str_extract(text, "^[A-Z ]{3,}:"))
test$speaker[1:10]
```

    ##  [1] NA NA NA NA NA NA NA NA NA NA

``` r
nrcjoy <- get_sentiments("nrc") %>% 
  filter(sentiment == "joy")

nrcsadness <- get_sentiments("nrc") %>% 
  filter(sentiment == "sadness")
grouped_joy <- test %>% 
    group_by(ep_nr) %>% 
    # iets van linenumbers toevoegen?
    mutate(linenumber = row_number()) %>% 
    unnest_tokens(word, text, token = "words") %>% 
    inner_join(nrcjoy) %>% 
    count(word, sort = TRUE)
```

    ## Joining, by = "word"

``` r
grouped_joy
```

    ## # A tibble: 702 x 3
    ## # Groups:   ep_nr [14]
    ##    ep_nr word      n
    ##    <int> <chr> <int>
    ##  1   647 good     33
    ##  2   653 good     29
    ##  3   644 good     25
    ##  4   646 good     25
    ##  5   641 good     24
    ##  6   648 good     23
    ##  7   642 good     22
    ##  8   645 good     22
    ##  9   645 kind     21
    ## 10   649 good     21
    ## # ... with 692 more rows

``` r
grouped_sadness <- test %>% 
    group_by(ep_nr) %>% 
    # iets van linenumbers toevoegen?
    mutate(linenumber = row_number()) %>% 
    unnest_tokens(word, text, token = "words") %>% 
    inner_join(nrcsadness) %>% 
    count(word, sort = TRUE)
```

    ## Joining, by = "word"

``` r
grouped_sadness
```

    ## # A tibble: 792 x 3
    ## # Groups:   ep_nr [14]
    ##    ep_nr word            n
    ##    <int> <chr>       <int>
    ##  1   648 problem        38
    ##  2   646 meltdown       34
    ##  3   641 problem        30
    ##  4   644 problem        29
    ##  5   655 problem        29
    ##  6   642 problem        27
    ##  7   645 speculation    24
    ##  8   647 meltdown       24
    ##  9   645 meltdown       22
    ## 10   645 problem        22
    ## # ... with 782 more rows

``` r
grouped_sent <- test %>% 
    group_by(ep_nr) %>% 
    # iets van linenumbers toevoegen?
    mutate(linenumber = row_number()) %>% 
    unnest_tokens(word, text, token = "words") %>% 
    group_by(ep_nr, linenumber) %>% 
    mutate(wordcount = n()) %>%
    group_by(ep_nr) %>% 
    inner_join(get_sentiments("bing")) %>%
    count(ep_nr, index = linenumber %/% 20, sentiment) %>%
    spread(sentiment, n, fill = 0) %>%
    mutate(sentiment = positive - negative)
```

    ## Joining, by = "word"

``` r
# maybe per sentence, /count words standardized sentiment

ggplot(grouped_sent, aes(index, sentiment, fill = ep_nr)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ep_nr, ncol = 2, scales = "free_x")
```

![](README_files/figure-markdown_github/unnamed-chunk-2-1.png)

moving average of sentiment over every podcast, per speaker?

``` r
sentiment_per_epi <- df_sn %>% 
    tidyr::unnest(text) %>% 
    mutate(speaker = str_extract(text, "^[A-Z ]{3,}:")) %>% 
    group_by(ep_nr,title ) %>% 
    mutate(linenumber = row_number()) %>% 
    unnest_tokens(word, text, token = "words") %>% 
    group_by(ep_nr,title , linenumber) %>% 
    mutate(wordcount = n()) %>%
    group_by(ep_nr,title ) %>% 
    inner_join(get_sentiments("bing")) %>%
    count(ep_nr,title , index = linenumber %/% 10, sentiment) %>%
    spread(sentiment, n, fill = 0) %>%
    mutate(sentiment = positive - negative) %>% 
    mutate(caption = paste(unique(ep_nr),"\n",unique(title), collapse = " "))
```

    ## Joining, by = "word"

``` r
{ggplot(sentiment_per_epi, aes(index, sentiment, fill = ep_nr)) +
    geom_col(show.legend = FALSE) +
    labs(title = "All episodes of Security Now! sentiment per 10 lines episode",
         subtitle = "Higher score is more positive (up is good!)",
         x = "", y = "sentiment")+ 
    ggthemes::theme_tufte()+
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank())+
    facet_wrap(~ep_nr, scales = "free_x")} %>% 
    ggsave(filename = "sentiment_p_ep_sn.png",
           width = 25, 
           height = 60, 
           dpi = 350,
           units = "cm")
```

Sentiment per episode mean?

``` r
sentiment_per_epi %>% 
    group_by(ep_nr) %>% 
    summarize(mean_sentiment = mean(sentiment)) %>% 
    left_join(df_sn %>% select(ep_nr,date), by = "ep_nr") %>% 
    mutate(year = gsub("^[A-z ]{3,}[0-9]{1,2},", "",date) %>% as.integer()) %>% 
    ggplot(aes(year, mean_sentiment))+
    geom_point()+
    geom_hline(yintercept = 0, color = "red")
```

    ## Warning in function_list[[k]](value): NAs introduced by coercion

    ## Warning: Removed 1 rows containing missing values (geom_point).

![](README_files/figure-markdown_github/unnamed-chunk-4-1.png)

generally a positive sentiment.
