###
library(markovifyR)
lessons <-
    linneman_lessons %>%
    pull(textLesson)

lessons %>% str()

#Step 2 -- Build the Model

markov_model <-
    generate_markovify_model(
        input_text = lessons,
        markov_state_size = 2L,
        max_overlap_total = 25,
        max_overlap_ratio = .85
    )

#Step 3 -- Generate the Text

markovify_text(
    markov_model = markov_model,
    maximum_sentence_length = NULL,
    output_column_name = 'textLinnemanBot',
    count = 25,
    tries = 100,
    only_distinct = TRUE,
    return_message = TRUE
)
