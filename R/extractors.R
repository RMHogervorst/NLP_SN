##  make set of functions that take basefile and extract info ----
get_episode_number <- function(lines){
    result <- lines[1:20]%>%
        .[grepl("EPISODE",.)] %>%
        stringr::str_extract("[0-9]{1,4}")
    if(length(result)==0){result <- NA}
    result %>% as.integer()
}
get_date <- function(lines){
    result <- lines[1:20] %>%
        .[grepl("^DATE:",.)] %>%
        sub("^DATE:\t+", "",.) # translate to real date here?
    if(length(result)==0){result <- NA}
    result
}

get_title <- function(lines){
    result <- lines[1:20] %>%
        .[grepl("^TITLE:",.)] %>%
        sub("^TITLE:\t+", "",.)
    if(length(result)==0){result <- NA}
    result
}

get_description <- function(lines){
    result <- lines[1:20] %>%
        .[grepl("^DESCRIPTION:",.)] %>%
        sub("^DESCRIPTION:", "",.) %>%
        str_trim() # reove spaces before and after
    if(length(result)==0){result <- NA}
    result
}

#Hosts
get_hosts <- function(lines){
    result <- lines[1:20] %>%
        .[grepl("^HOSTS:|^SPEAKERS:",.)] %>%
        sub("^HOSTS:|^SPEAKERS:", "",.) %>%
        gsub("\t", "",.) %>%
        str_trim("both") %>%
        strsplit("&")
    if(length(result)==0){result <- NA}
    result
}
#get tease SHOW TEASE:
get_teaser <- function(lines){
    result <- lines[1:20] %>%
        .[grepl("^SHOW TEASE:",.)] %>%
        sub("^SHOW TEASE:", "",.) %>%
        str_trim()
    if(length(result)==0){result <- NA}
    result
}

#get source
get_source <- function(lines){
    result <- lines[1:20] %>%
        .[grepl("^SOURCE:",.)] %>%
        sub("^SOURCE:\t+", "",.) %>%
        str_trim()
    if(length(result)==0){result <- NA}
    result
}

### AN EXTRACTOR FOR THIS SPECIFIC TASK
# FIND LEO LAPORTE:  OR STEVE GIBSON: OR FIND PATTERN with
# only caps spaces :
#sample <- read_lines("data/sn-617.txt")
#grep(pattern = "^[A-Z]{2,}",x = sample) # beter
#grep("^.*:", sample)
#grep("^$", sample) # empty lines
# remove empty lines
# grep named ones, aggregate up.
# remove top 10 lines, and lines that start with DATE, TITLE, EPISODE, HOST,
# SOURCE, DESCRIPTION, SHOW TEASE, ARCHIVE

extract_voices <- function(lines){
    lines_in <- lines[10:length(lines)]
    lines_without_empty <- lines_in[!grepl("^$",lines_in)]
    MATCHSTRING <- "^DATE|^TITLE|^EPISODE|^HOST|^SOURCE|^DESCRIPTION|^Copyright|^DESCRIPTION|^SHOW TEASE|^ARCHIVE|^GIBSON RESEARCH CORPORATION"
    lines_final <- lines_without_empty[!grepl(MATCHSTRING,lines_without_empty)]
    # indicators
    startlines <- grep("^[A-Z]{2,}",lines_final)
    stoplines <- startlines -1    #logically the one before the start is stop
    stoplines<-stoplines[-1]   # the first one cannot be 0
    stoplines <- stoplines[!stoplines %in% startlines]   # remove the ones that are the same
    # ik wil een set van indexen
    # 1:2
    # 3:6
    # match stopline+1 == ding. doe an bij vorige?

    match_function <- function(x){
        match <- stoplines[stoplines+1 ==x]
        result <- if(length(match)==0){NA}else{match}
        result
    }

    stoppoints <- map_dbl(startlines, match_function)
    stoplines2 <- append(stoppoints[-1], values = NA)

    holdingframe <- data_frame(
        startline = startlines,
        stopline = stoplines2) %>%
        mutate(stopline = ifelse(is.na(stopline),startline, stopline),
               instructions = map2(startline, stopline, seq))
    text_extract <- function(instructions, file){
        paste(file[unlist(instructions)], collapse = " ")
    }


    result <- map_chr(holdingframe$instructions, text_extract, lines_final)
    result
}

#testfile <- extract_voices(sample)


unify_names <- function(name) {
    case_when(name == "LEO LAPORTE" ~  "LEO",
              name ==   "STEVE GIBSON" ~ "STEVE",
              name == "MIKE ELGAN" ~ "MIKE",
              name =="FATHER ROBERT BALLECER" ~ "PADRE",
              name == "JASON HOWELL" ~ "JASON",
              name == "FR. ROBERT" ~ "PADRE", # yes it's the same person
              name == "MARC MAIFFRET" ~ "MARC",
              name == "TOM MERRITT" ~ "TOM",
              name == "IYAZ AKHTAR" ~ "IYAZ",
              TRUE ~ NA_character_
    )
}

make_text_df <- . %>%
    data_frame(linenr = seq_len(length(.)),
               text = .) %>%
    mutate(
        speaker = str_extract(text, "^[\"A-Z ]{2,}:") %>%
            gsub(pattern = ":","", .) %>%
            str_trim("both"),
        text = str_replace(text, "^[\"A-Z ]{2,}:", "") %>%
            str_trim("both"),
        speaker = unify_names(speaker)
    )

combine_voices_into_df <- . %>% extract_voices() %>% make_text_df()
