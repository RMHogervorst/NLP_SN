Security now! scraper
================

First things first:

I will read in all of the SN transcripts, those are txt files so in a way we are not even scraping but just reading in 700 or so text files which is not really a big deal. However: In general it is neice if you ask permission (I did) and don't push the website to its limit. the GRC servers are quite beefy and I will probably not even make a dent in them.

There are multiple ways I could do this: if I had used rvest to scrape a website I would have set a user-agent header[1] and I would have used incremental backoff when the server refuses a connection we would wait and retry again, if it still refuses we would wait twice as long and retry again etc.

However in this project we can just use read\_lines[2] to read the txt file of a transcript and apply further work downstream.

The txt file is very nicely structured, that means we can extract pieces that contain the metadata. *See the scraper.R file in the folder R*

I have now downloaded everything into memory. which is not readly failt tolerant. it also takes very long, and since I dont' know how long it takes and if the scraper stops somewhere, I have added a helperfunction tgat prints to the screen[3]

It did indeed fail in between and so I had to redownload files.

**Now that I've downloaded all the transcripts I have to extract features from the files** You can find more about the extraction in [extracting features](extracting_features)

### about this document:

If you think this looks polished and that I am the wizard of R, think again, and read through the git commits on github. You will see that I make stupid mistakes and correct them later on. So learn from your missteps and put them online, I encourage you and hope to see you soon.

[1] a piece of information we snd with every request that describes who we are

[2] This is the readr variant of readLines from base-R, it is much faster then the original

[3] This is not really a pure function anymore, but it has side effects (it both reads and print where it is) but I needed to know where it failed
