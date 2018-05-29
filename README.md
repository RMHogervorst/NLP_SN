README
================

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active) [![Last-changedate](https://img.shields.io/badge/last%20change-2018--05--29-yellowgreen.svg)](/commits/master) [![license](https://img.shields.io/github/license/mashape/apistatus.svg)](http://choosealicense.com/licenses/mit/)

In this project I will apply some text (NLP ) analyses on all the transcripts from security now (SN) episodes.

SN is a highly informative podcast by Steve Gibson and Leo Laporte about security related news and or explanations of concepts. The series is long running for almost 13 years at the time of writing. In the early years there were entire episodes dedicated to a certain topic, later on the security related news has taken more of a foreground.

Steve has someone transcribe all of the audio files, that means we can use NLP tools to analyze all of the text.

I've only listened to the last few years so that is what I'm most interested in.

What does the data look like?
-----------------------------

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

As you can see this text is very structured and is somewhat easily parsed into analysis-ready data.

This project has two parts:

-   build a [scraper](SCRAPER_description.md) that downloads/ reads in all of the text
    -   \[x\] iterate through all of the links (don't download if you already have it)
    -   \[x\] extract the metadata on top of the file (Date, Title, speakers, sourcefile, Description)
    -   \[x\] a row per sentence
-   build cool stuff on top of this file
    -   classifier that predicts who speaks?\*
    -   \[x\] sentiment analyses per episode, per season
    -   \[x\] bot that talks like Steve and Leo\*
    -   topic model or word2vec\*
    -   network analysis of words

Building a scraper
------------------

The scraping part I've kept relatively easy, I knew the files were in txt format and very structered on the website. I chose to just generate a set of links and download the files, check them for errors and read the files in.

More details can be found on the page [scraper\_description](SCRAPER_description.md)

Building extraction tools
-------------------------

I extracted all the episode information, title, date, hosts, episode number, description and extracted all the lines that contained spoken text, identified the speaker created a linenumber and combined that all into 1 dataframe.

[More info in the part extracting features](extracting_features.md)

Final product:

A dataframe with a row for every episode and normal columns for episode information, and 1 list-column containing a new dataframe with a linenumber, speaker, and what text was spoken.

Actually the deleting of files and reading into a dataframe were done in the extracting features file.
