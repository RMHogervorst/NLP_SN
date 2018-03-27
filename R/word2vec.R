## word2vec functions



slide_windows <- function(tbl, doc_var, window_size) {
    # each word gets a skipgram (window_size words) starting on the first
    # e.g. skipgram 1 starts on word 1, skipgram 2 starts on word 2

    each_total <- tbl %>%
        group_by(!!doc_var) %>%
        mutate(doc_total = n(),
               each_total = pmin(doc_total, window_size, na.rm = TRUE)) %>%
        pull(each_total)

    rle_each <- rle(each_total)
    counts <- rle_each[["lengths"]]
    counts[rle_each$values != window_size] <- 1

    # each word get a skipgram window, starting on the first
    # account for documents shorter than window
    id_counts <- rep(rle_each$values, counts)
    window_id <- rep(seq_along(id_counts), id_counts)


    # within each skipgram, there are window_size many offsets
    indexer <- (seq_along(rle_each[["values"]]) - 1) %>%
        map2(rle_each[["values"]] - 1,
             ~ seq.int(.x, .x + .y)) %>%
        map2(counts, ~ rep(.x, .y)) %>%
        flatten_int() +
        window_id

    tbl[indexer, ] %>%
        bind_cols(data_frame(window_id)) %>%
        group_by(window_id) %>%
        filter(n_distinct(!!doc_var) == 1) %>%
        ungroup
}


nearest_synonyms <- function(df, token) {
    df %>%
        widely(~ . %*% (.[token, ]), sort = TRUE)(item1, dimension, value) %>%
        select(-item2)
}

analogy <- function(df, token1, token2, token3) {
    df %>%
        widely(~ . %*% (.[token1, ] - .[token2, ] + .[token3, ]), sort = TRUE)(item1, dimension, value) %>%
        select(-item2)

}

