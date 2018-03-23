# scraper
library(stringr)
library(readr)
library(purrr)
library(tibble)
library(dplyr)
library(magrittr)
library(curl)
# Apply to 1, apply to everyone
#basefile <- readr::read_lines(file = "https://www.grc.com/sn/sn-594.txt")
# seems like 15 rows is enough information for the top of the file
#basefile[1:15] %>% .[grepl("EPISODE",.)] %>% stringr::str_extract("[0-9]{1,4}")
### combining small functions into a single function. ---
#rowbased?
# add all links at the same time?


download_file <- function(file){
    filename <- basename(file)
    if(file.exists(paste0("data/",filename))){
        print(paste("file exists: ",filename))
    }else{
        print(paste0("downloading file:", file))
        h <- new_handle(failonerror = FALSE)
        h <- handle_setheaders(h, "User-Agent"= "scraper by RM Hogervorst, @rmhoge, gh: rmhogervorst")
        curl_download(url = file,destfile = paste0("data/",filename),mode = "wb", handle = h)
        Sys.sleep(sample(seq(0,2,0.5), 1)) # copied this from  Bob Rudis(@hrbrmstr)
    }
}

latest_episode <- 636
#downloading
walk(paste0("https://www.grc.com/sn/sn-",
           formatC(1:latest_episode, width = 3,flag = 0),".txt"), download_file)
# we choose walk here, because we don't expect output (we do get prints)
# We specificaly do this for the side-effect: downloading to a folder.







## from CAPS: to "" line into 1 piece per person. Or
