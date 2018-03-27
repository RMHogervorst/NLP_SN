## put into dataframe
## found this idea in excellent tidytextmining book by Julia Silge and David Robinson (tidytextmining.com)
## to see where we are this function wraps read_lines and prints
library(magrittr)
library(dplyr)
library(purrr)
library(readr)

# a function that deletes files that are probably html error codes.
# also
delete_html_empties <- function(file, debug = FALSE){
    if(debug) print(file)
    sample_doc <- read_lines(file = file, n_max = 1)
    if(length(sample_doc)==0){
        message("deleting sample ", file)
        file.remove(file)
    }else if(grepl(pattern = "^<DOCTYPE html", sample_doc )){
        # it failed here, because the control flow of the program tried to do something with the
        # file, but it was already deleted.
        message("deleting sample ", file)
        file.remove(file)
    }

}
all_txt_in_folder <- dir(path = "data/", pattern = "*.txt", full.names = TRUE)

walk(all_txt_in_folder, delete_html_empties)

# A read lines copy that also prints the filename to the console,
# useful if you don't know where your program fails.
# Bob Rudis (hrbmstr) has created scrapers that show progress bars
# https://rud.is/b/2017/05/05/scrapeover-friday-a-k-a-another-r-scraping-makeover/
#
read_lines2 <- function(file){
    print(file)
    read_lines(file)
}

system.time(
    df_sn <- all_txt_in_folder %>%
        tibble(path = .) %>%
        mutate(transcript = map(path, read_lines))
)
## read_lines2: user 2.00, system 1.71, elapsed 17.32
## read_lines: user 0.61, system 1.05, elapsed 1.69  (crazy slowdown by print!)
# object is object.size(df_sn)   57425648 bytes
# weird: now: user 2.52, system 2.67. elapsed 26.11
# 0.537   0.147   0.999
# Seems that it was more a memory allocation thingy. if you run it twice you
# get faster results because the memory was already allocated.
df_sn %<>%
    mutate(source = map_chr(transcript, get_source),
           date = map_chr(transcript, get_date), #
           description = map_chr(transcript, get_description) ,
           ep_nr =map_int(transcript, get_episode_number) ,
           hosts =map(transcript, get_hosts) ,  # these are multiples, and not single character vec
           teaser = map_chr(transcript, get_teaser),
           title =map_chr(transcript, get_title),
           text = map(transcript, combine_voices_into_df)) %>%
    select(-transcript)


write_rds(df_sn, "df_sn.RDS")

