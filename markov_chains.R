###
library(markovifyR)
library(dplyr)
df_sn <- readr::read_rds("df_sn.RDS")
steveonly <- df_sn %>% tidyr::unnest(text) %>%
    filter(speaker == "STEVE")
#Step 2 -- Build the Model

markov_model <-
    generate_markovify_model(
        input_text = steveonly$text, # maybe filter on length >5?
        markov_state_size = 2L,
        max_overlap_total = 25,
        max_overlap_ratio = .85
    )

#Step 3 -- Generate the Text

texts_gen <- markovify_text(
    markov_model = markov_model,
    maximum_sentence_length = NULL,
    output_column_name = 'steve',
    count = 300,
    tries = 100,
    only_distinct = TRUE,
    return_message = FALSE
)
readr::write_rds(texts_gen, "texts_gen.rds")

markovify_text(
    markov_model = markov_model,
    maximum_sentence_length = NULL,
    start_words = c("The", "You", "Life"),
    output_column_name = 'steve',
    count = 25,
    tries = 100,
    only_distinct = TRUE,
    return_message = TRUE
)

generate_start_words(markov_model = markov_model)
